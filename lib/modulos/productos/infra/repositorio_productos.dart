import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/mapper/producto_mapper.dart';

class RepositorioProductos extends Repositorio
    implements IRepositorioProductos {
  final _tablaProductos = 'productos';
  final _tablaCategorias = 'categorias';
  final _consultas = Dependencias.productos.repositorioConsultasProductos();

  RepositorioProductos({
    required ISync syncAdapter,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(syncAdapter, db);

  @override
  Future<Map<String, Object>> obtenerNombreYCodigo(UID uid) async {
    var query =
        'SELECT nombre, codigo, bloqueado, borrado from productos WHERE uid = ?';
    Map<String, Object> result = {};

    var dbResult = await db.query(sql: query, params: [uid.toString()]);

    for (var row in dbResult) {
      result['nombre'] = row['nombre'] as String;
      result['codigo'] = row['codigo'] as String;
      result['bloqueado'] = row['bloqueado'] as int;
      result['borrado'] = row['borrado'] as int;
    }

    return result;
  }

  @override
  Future<void> agregar(Producto producto) async {
    await adaptadorSync.sincronizar(
      dataset: 'productos',
      rowID: producto.uid.toString(),
      campos: {
        'codigo': producto.codigo,
        'nombre': producto.nombre,
        if (producto.categoria != null)
          if (UID.isValid(producto.categoria!.uid.toString()))
            'categoria_uid': producto.categoria!.uid.toString(),
        'unidad_medida_uid': producto.unidadMedida.uid.toString(),
        'precio_compra': producto.precioDeCompra.serialize(),
        'precio_venta': producto.precioDeVenta.serialize(),
        'se_vende_por': producto.seVendePor.index,
        'url_imagen': producto.imagenURL,
        'preguntar_precio': producto.preguntarPrecio,
        'version_actual_uid': producto.versionActual.toString(),
      },
    );

    await adaptadorSync.sincronizar(
      dataset: 'productos_versiones',
      rowID: producto.versionActual.toString(),
      campos: {
        'producto_uid': producto.uid.toString(),
        'codigo': producto.codigo,
        'nombre': producto.nombre,
        if (producto.categoria != null)
          if (UID.isValid(producto.categoria!.uid.toString()))
            'categoria_nombre': producto.categoria!.nombre.toString(),
        'unidad_medida_nombre': producto.unidadMedida.nombre.toString(),
        'unidad_medida_abreviacion':
            producto.unidadMedida.abreviacion.toString(),
        'precio_compra': producto.precioDeCompra.serialize(),
        'precio_venta': producto.precioDeVenta.serialize(),
        'se_vende_por': producto.seVendePor.index,
        'url_imagen': producto.imagenURL,
        'guardado_en': DateTime.now().millisecondsSinceEpoch,
      },
    );

    //TODO:explorar tipo "asociar" para este tipo de relaciones
    for (var impuesto in producto.impuestos) {
      await adaptadorSync.sincronizar(
        dataset: 'productos_impuestos',
        rowID: producto.uid.toString(),
        campos: {
          'uid': UID().toString(),
          'producto_uid': producto.uid.toString(),
          'impuesto_uid': impuesto.uid.toString(),
        },
      );
    }
  }

  @override
  Future<void> agregarCategoria(Categoria categoria) async {
    await adaptadorSync.sincronizar(
      dataset: 'categorias',
      rowID: categoria.uid.toString(),
      campos: {
        'nombre': categoria.nombre,
      },
    );
  }

  @override
  Future<void> eliminar(UID id) async {
    await adaptadorSync.sincronizar(
      dataset: 'productos',
      rowID: id.toString(),
      campos: {
        'borrado': true,
      },
    );
  }

  @override
  Future<void> modificar(Producto productoModificado) async {
    Producto? productoOriginal =
        await _consultas.obtenerProducto(productoModificado.uid);

    if (productoOriginal != null) {
      // Creamos una nueva version del producto con los datos modificados
      productoModificado = productoModificado.copyWith(versionActual: UID());

      // Realizamos la modificacion con el sync engine
      var diferencias = await obtenerDiferencias(
        ProductoMapper.domainAMap(productoModificado),
        ProductoMapper.domainAMap(productoOriginal),
      );

      // Solo creamos una nueva version si hubo al menos un cambio
      if (diferencias.isNotEmpty) {
        // Actualizar el producto original
        await adaptadorSync.sincronizar(
          dataset: 'productos',
          rowID: productoModificado.uid.toString(),
          campos: diferencias,
        );

        //Crear la version del producto
        await adaptadorSync.sincronizar(
          dataset: 'productos_versiones',
          rowID: productoModificado.versionActual.toString(),
          campos: {
            'producto_uid': productoModificado.uid.toString(),
            'codigo': productoModificado.codigo,
            'nombre': productoModificado.nombre,
            if (productoModificado.categoria != null)
              if (UID.isValid(productoModificado.categoria!.uid.toString()))
                'categoria_nombre':
                    productoModificado.categoria!.nombre.toString(),
            'unidad_medida_nombre':
                productoModificado.unidadMedida.nombre.toString(),
            'unidad_medida_abreviacion':
                productoModificado.unidadMedida.abreviacion.toString(),
            'precio_compra': productoModificado.precioDeCompra.serialize(),
            'precio_venta': productoModificado.precioDeVenta.serialize(),
            'se_vende_por': productoModificado.seVendePor.index,
            'url_imagen': productoModificado.imagenURL,
            'preguntar_precio': productoModificado.preguntarPrecio,
            'guardado_en': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }

      await adaptadorSync.sincronizar(
        dataset: _tablaProductos,
        rowID: productoModificado.uid.toString(),
        campos: diferencias,
      );

      //TODO: simplificar esto

      var difImpuestos = obtenerDiferenciasDeListasDeRelaciones<Impuesto>(
        productoModificado.impuestos,
        productoOriginal.impuestos,
      );

      for (var impuesto in difImpuestos.agregados) {
        await adaptadorSync.sincronizar(
          dataset: 'productos_impuestos',
          rowID: UID().toString(),
          campos: {
            'producto_uid': productoModificado.uid.toString(),
            'impuesto_uid': impuesto.uid.toString(),
          },
        );
      }

      for (var impuesto in difImpuestos.eliminados) {
        var relacionUID = await _consultas.obtenerRelacionProductoImpuesto(
          productoModificado.uid,
          impuesto.uid,
        );

        await adaptadorSync.sincronizar(
          dataset: 'productos_impuestos',
          rowID: relacionUID.toString(),
          campos: {
            'borrado': true,
          },
        );
      }
    } else {
      throw ValidationEx(
        tipo: TipoValidationEx.entidadNoExiste,
        mensaje:
            'No existe la entidad en la base de datos, codigo: ${productoModificado.uid.toString()}',
      );
    }
  }

  @override
  Future<void> guardarConfigCompartida(
      ConfigCompartidaDeProductos config) async {
    await adaptadorSync.sincronizar(
      dataset: 'config_productos',
      rowID: config.uid.toString(),
      campos: {'permitirPrecioCompraCero': config.permitirPrecioCompraCero},
    );
  }

  @override
  Future<ConfigCompartidaDeProductos> obtenerConfigCompartida() async {
    ConfigCompartidaDeProductos configCompartida;
    var query = 'SELECT * FROM config_productos';

    var dbResult = await db.query(sql: query);

    if (dbResult.length == 1) {
      configCompartida = ConfigCompartidaDeProductos.cargar(
        uid: UID.fromString(dbResult.first['uid'].toString()),
        permitirPrecioCompraCero: Utils.db
            .intToBool(dbResult.first['permitirPrecioCompraCero'] as int),
      );
    } else {
      throw ValidationEx(
          tipo: TipoValidationEx.argumentoInvalido,
          mensaje: 'No hay valores de configuración del módulo productos');
    }

    return configCompartida;
  }

  @override
  Future<void> eliminarCategoria(UID uid) async {
    await adaptadorSync.sincronizar(
      dataset: _tablaCategorias,
      rowID: uid.toString(),
      campos: {
        'borrado': true,
      },
    );
  }

  @override
  Future<void> modificarCategoria(Categoria categoriaModificada) async {
    Categoria? categoriaOriginal =
        await _consultas.obtenerCategoria(categoriaModificada.uid);

    if (categoriaOriginal != null) {
      var diferencias = await obtenerDiferencias(
        categoriaModificada.toMap(),
        categoriaOriginal.toMap(),
      );

      await adaptadorSync.sincronizar(
        dataset: _tablaCategorias,
        rowID: categoriaModificada.uid.toString(),
        campos: diferencias,
      );
    } else {
      throw ValidationEx(
        tipo: TipoValidationEx.entidadYaExiste,
        mensaje:
            'No existe la categoria en la base de datos, codigo: ${categoriaModificada.uid.toString()}',
      );
    }
  }
}
