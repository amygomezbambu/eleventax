import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/mapper/producto_mapper.dart';

import 'package:eleventa/modulos/common/domain/moneda.dart';

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
  Future<void> borrar(UID id) {
    throw UnimplementedError();
  }

  @override
  Future<void> actualizar(Producto producto) async {
    var dbResult = await db.query(
      sql:
          'SELECT uid,codigo,nombre,categoria,precio_compra,precio_venta,se_vende_por,url_imagen, preguntar_precio '
          'FROM productos WHERE uid = ?',
      params: [producto.uid.toString()],
    );

    if (dbResult.isNotEmpty) {
      var row = dbResult[0];
      var productoDB = ProductoMapper.databaseADomain(row);

      var diferencias = await obtenerDiferencias(
        ProductoMapper.domainAMap(producto),
        ProductoMapper.domainAMap(productoDB),
      );

      //El motor de sincronización y la db no trabajan con entidades o value objects
      //directamente por lo que debemos convertir los tipos especiales a un tipo que ellos
      //entiendan
      for (var diferencia in diferencias.keys) {
        if (diferencias[diferencia] is Moneda) {
          diferencias[diferencia] =
              (diferencias[diferencia] as Moneda).toMonedaInt();
        }
      }

      await adaptadorSync.synchronize(
        dataset: 'productos',
        rowID: producto.uid.toString(),
        fields: diferencias,
      );
    } else {
      throw EleventaEx(
        message: 'No existe la entidad en la base de datos',
        input: producto.toString(),
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
