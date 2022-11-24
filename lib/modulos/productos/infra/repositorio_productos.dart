import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/mapper/producto_mapper.dart';

class RepositorioProductos extends Repositorio
    implements IRepositorioProductos {
  final _consultas = Dependencias.productos.repositorioConsultasProductos();

  RepositorioProductos({
    required ISync syncAdapter,
    required IAdaptadorDeBaseDeDatos db,
  }) : super(syncAdapter, db);

  @override
  Future<void> agregar(Producto producto) async {
    await adaptadorSync.synchronize(
      dataset: 'productos',
      rowID: producto.uid.toString(),
      fields: {
        'codigo': producto.codigo,
        'nombre': producto.nombre,
        if (producto.categoria != null)
          if (UID.isValid(producto.categoria!.uid.toString()))
            'categoria_uid': producto.categoria!.uid.toString(),
        'unidad_medida_uid': producto.unidadMedida.uid.toString(),
        'precio_compra': producto.precioDeCompra.toMonedaInt(),
        if (producto.precioDeVenta != null)
          'precio_venta': producto.precioDeVenta!.toMonedaInt(),
        'se_vende_por': producto.seVendePor.index,
        'url_imagen': producto.imagenURL,
        'preguntar_precio': producto.preguntarPrecio,
      },
    );

    for (var impuesto in producto.impuestos) {
      await adaptadorSync.synchronize(
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
  Future<List<Producto>> obtenerTodos() async {
    return _consultas.obtenerProductos();
  }

  @override
  Future<void> eliminar(UID id) async {
    await adaptadorSync.synchronize(
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

      await adaptadorSync.synchronize(
        dataset: 'productos',
        rowID: productoModificado.uid.toString(),
        fields: diferencias,
      );

      var difImpuestos = obtenerDiferenciasDeListasDeRelaciones<Impuesto>(
        productoModificado.impuestos,
        productoOriginal.impuestos,
      );

      for (var impuesto in difImpuestos.agregados) {
        await adaptadorSync.synchronize(
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

        await adaptadorSync.synchronize(
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
    await adaptadorSync.synchronize(
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
}
