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
      fields: {
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
      },
    );

    for (var impuesto in producto.impuestos) {
      await adaptadorSync.sincronizar(
        dataset: 'productos_impuestos',
        rowID: producto.uid.toString(),
        fields: {
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
      fields: {
        'nombre': categoria.nombre,
      },
    );
  }

  @override
  Future<void> eliminar(UID id) async {
    await adaptadorSync.sincronizar(
      dataset: 'productos',
      rowID: id.toString(),
      fields: {
        'borrado': true,
      },
    );
  }

  @override
  Future<void> modificar(Producto productoModificado) async {
    Producto? productoOriginal =
        await _consultas.obtenerProducto(productoModificado.uid);

    if (productoOriginal != null) {
      var diferencias = await obtenerDiferencias(
        ProductoMapper.domainAMap(productoModificado),
        ProductoMapper.domainAMap(productoOriginal),
      );

      await adaptadorSync.sincronizar(
        dataset: _tablaProductos,
        rowID: productoModificado.uid.toString(),
        fields: diferencias,
      );

      var difImpuestos = obtenerDiferenciasDeListasDeRelaciones<Impuesto>(
        productoModificado.impuestos,
        productoOriginal.impuestos,
      );

      for (var impuesto in difImpuestos.agregados) {
        await adaptadorSync.sincronizar(
          dataset: 'productos_impuestos',
          rowID: UID().toString(),
          fields: {
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
          fields: {
            'borrado': true,
          },
        );
      }
    } else {
      throw EleventaEx(
        message:
            'No existe la entidad en la base de datos, codigo: ${productoModificado.uid.toString()}',
        input: productoModificado.toString(),
      );
    }
  }

  @override
  Future<void> guardarConfigCompartida(
      ConfigCompartidaDeProductos config) async {
    await adaptadorSync.sincronizar(
      dataset: 'config_productos',
      rowID: config.uid.toString(),
      fields: {'permitirPrecioCompraCero': config.permitirPrecioCompraCero},
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
      throw EleventaEx(
          message: 'No hay valores de configuración del módulo productos');
    }

    return configCompartida;
  }

  @override
  Future<void> eliminarCategoria(UID uid) async {
    await adaptadorSync.sincronizar(
      dataset: _tablaCategorias,
      rowID: uid.toString(),
      fields: {
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
        fields: diferencias,
      );
    } else {
      throw EleventaEx(
        message:
            'No existe la categoria en la base de datos, codigo: ${categoriaModificada.uid.toString()}',
        input: categoriaModificada.toString(),
      );
    }
  }
}
