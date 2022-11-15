import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
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
  Future<Producto?> obtenerPorCodigo(String codigo) async {
    return await _obtenerProducto('p.codigo = ?', [codigo]);
  }

  @override
  Future<Producto?> obtener(UID uid) async {
    return await _obtenerProducto('p.uid = ?', [uid.toString()]);
  }

  Future<Producto?> _obtenerProducto(
      String condicionWhere, List<Object?> params) async {
    var query =
        'SELECT p.uid,p.codigo,p.nombre,p.categoria_uid,p.precio_compra,p.precio_venta,'
        'p.se_vende_por,p.url_imagen,c.nombre AS categoria,um.nombre as unidad_medida_nombre, '
        'um.abreviacion as unidad_medida_abreviacion, p.unidad_medida_uid, p.preguntar_precio '
        'FROM productos p '
        'LEFT JOIN productos_categorias c on p.categoria_uid = c.uid '
        'LEFT JOIN unidades_medida um on p.unidad_medida_uid = um.uid '
        'WHERE $condicionWhere';

    var result = await db.query(sql: query, params: params);

    Producto? producto;

    for (var row in result) {
      producto = Producto.cargar(
          uid: UID.fromString(row['uid'] as String),
          nombre: NombreProducto(row['nombre'] as String),
          precioDeVenta: PrecioDeVentaProducto(
              Moneda.fromMonedaInt(row['precio_venta'] as int)),
          precioDeCompra: PrecioDeCompraProducto(
            Moneda.fromMonedaInt(row['precio_compra'] as int),
          ),
          codigo: CodigoProducto(row['codigo'] as String),
          unidadDeMedida: UnidadDeMedida(
            uid: UID.fromString(row['unidad_medida_uid'] as String),
            nombre: row['unidad_medida_nombre'] as String,
            abreviacion: row['unidad_medida_abreviacion'] as String,
          ),
          seVendePor: ProductoSeVendePor.values[row['se_vende_por'] as int],
          categoria: row['categoria_uid'] == null
              ? null
              : Categoria(
                  uid: UID.fromString(row['categoria_uid'] as String),
                  nombre: row['categoria'] as String),
          imagenURL: row['url_imagen'] as String,
          preguntarPrecio: Utils.db.intToBool(row['preguntar_precio'] as int));
    }

    return producto;
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
