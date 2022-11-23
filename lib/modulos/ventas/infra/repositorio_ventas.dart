import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/domain/entity/articulo_de_venta.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';

class RepositorioVentas extends Repositorio implements IRepositorioDeVentas {
  final syncModuleName = 'ventas';
  final tabla = 'ventas';

  RepositorioVentas(
      {required ISync syncAdapter, required IAdaptadorDeBaseDeDatos db})
      : super(syncAdapter, db);

  @override
  Future<void> agregar(Venta venta) async {
    var command =
        'INSERT INTO ventas(uid, nombre, total, status) VALUES(?,?,?,?)';

    await db.command(sql: command, params: [
      venta.uid.toString(),
      venta.nombre,
      venta.total,
      venta.status.index
    ]);
  }

  @override
  Future<void> agregarArticuloDeVenta(ArticuloDeVenta articulo) async {
    var command =
        'INSERT INTO articulos_de_venta(venta_uid, producto_uid, cantidad) VALUES(?,?,?)';

    try {
      await db.command(sql: command, params: [
        articulo.ventaUID.toString(),
        articulo.productoUID.toString(),
        articulo.cantidad
      ]);
    } catch (error, stack) {
      throw InfraEx(
        message:
            'Ocurrio un error al intentar almacenar el articulo de venta en la base de datos.',
        innerException: error as Exception,
        stackTrace: stack,
        input: articulo.toString(),
      );
    }
  }

  @override
  Future<void> actualizarDatosDePago(Venta venta) async {
    var command =
        'UPDATE ventas set metodo_de_pago = ?, status = ?, fecha_de_pago = ? '
        'WHERE uid = ?';

    if (venta.metodoDePago == null) {
      throw Exception('No esta establecido el metodo de pago');
    }

    if (venta.fechaDePago == null) {
      throw Exception('No esta establecida la fecha del pago');
    }

    await db.command(sql: command, params: [
      venta.metodoDePago!.index,
      venta.status.index,
      venta.fechaDePago!,
      venta.uid.toString(),
    ]);
  }

  @override
  Future<void> modificar(Venta venta) async {
    var command =
        'UPDATE ventas set nombre = ?, total = ?, status = ?, metodo_de_pago = ?, fecha_de_pago = ? '
        ' WHERE uid = ?';

    var params = <Object?>[];
    params.add(venta.nombre);
    params.add(venta.total);
    params.add(venta.status.index);

    if (venta.metodoDePago != null) {
      params.add(venta.metodoDePago!.index);
    } else {
      params.add(MetodoDePago.sinDefinir.index);
    }

    params.add(venta.fechaDePago);

    params.add(venta.uid.toString());

    await db.command(sql: command, params: params);
  }

  // @override
  // Future<Venta?> obtener(UID uid) async {
  //   var query =
  //       'SELECT uid,nombre,total,status,metodo_de_pago,fecha_de_pago FROM ventas '
  //       'WHERE uid = ?';

  //   var dbResult = await db.query(sql: query, params: [uid.toString()]);
  //   Venta? venta;

  //   for (var row in dbResult) {
  //     var statusIndex = row['status'] as int;

  //     venta = Venta.cargar(
  //       uid: UID.fromString(row['uid'] as String),
  //       nombre: row['nombre'] as String,
  //       total: row['total'] as double,
  //       status: EstadoDeVenta.values[statusIndex],
  //       metodoDePago: row['metodo_de_pago'] == null
  //           ? null
  //           : MetodoDePago.values[(row['metodo_de_pago'] as int)],
  //       fechaDePago:
  //           row['fecha_de_pago'] == null ? null : row['fecha_de_pago'] as int,
  //     );
  //   }

  //   return venta;
  // }

  @override
  Future<void> borrar(UID id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Venta>> obtenerTodos() {
    throw UnimplementedError();
  }

  @override
  Future<void> guardarConfigCompartida(ConfigCompartidaDeVentas config) async {
    await adaptadorSync.synchronize(
      dataset: 'config_ventas',
      rowID: config.uid.toString(),
      fields: {
        'permitirProductoComun': config.permitirProductoComun,
        'permitirCostoZero': config.permitirCostoZero
      },
    );
  }

  @override
  Future<ConfigCompartidaDeVentas> obtenerConfigCompartida() async {
    ConfigCompartidaDeVentas configCompartida;

    var query = 'SELECT * FROM config_ventas';

    var dbResult = await db.query(sql: query);

    if (dbResult.length == 1) {
      configCompartida = ConfigCompartidaDeVentas.cargar(
        uid: UID.fromString(dbResult.first['uid'].toString()),
        permitirProductoComun:
            Utils.db.intToBool(dbResult.first['permitirProductoComun'] as int),
        permitirCostoZero:
            Utils.db.intToBool(dbResult.first['permitirCostoZero'] as int),
      );
    } else {
      throw EleventaEx(message: 'No hay valores de configuración del módulo');
    }

    return configCompartida;
  }
}
