import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/infra/adaptador_dispositivo.dart';
import 'package:eleventa/modulos/common/infra/logger.dart';
import 'package:eleventa/modulos/common/infra/adaptador_sqlite.dart';
import 'package:eleventa/modulos/common/infra/adaptador_telemetria.dart';
import 'package:eleventa/modulos/common/infra/network/adaptador_red.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_productos.dart';
import 'package:eleventa/modulos/migraciones/migrar_db.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/telemetria/modulo_telemetria.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/infra/repositorio_ventas.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:flutter/material.dart';

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class Loader {
  late IAdaptadorDeBaseDeDatos adaptadorDB;
  late ILogger logger;

  /* #region Singleton */
  static final Loader _instance = Loader._internal();

  factory Loader() {
    return _instance;
  }

  Loader._internal();
  /* #endregion */

  Future<void> iniciarLogging() async {
    logger = Dependencias.infra.logger();

    await logger.iniciar(
      config: LoggerConfig(
        nivelesRemotos: [NivelDeLog.error],
        nivelesDeArchivo: [NivelDeLog.error, NivelDeLog.warning],
        nivelesDeConsola: [NivelDeLog.all],
      ),
    );
  }

  Future<void> iniciarSync() async {
    var sync_ = Sync.init(
      syncConfig: SyncConfig.create(
        dbVersionTable: 'migrations',
        dbVersionField: 'version',
        groupId: 'CH0001',
        deviceId: appConfig.deviceId.toString(),
        addChangesEndpoint:
            'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync',
        getChangesEndpoint:
            'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync-get-changes',
        deleteChangesEndpoint: 'http://localhost:3000/sync-delete-changes',
        pullInterval: 10000,
        onError: (ex, stack) {
          Dependencias.infra.logger().error(ex: ex, stackTrace: stack);
          throw ex;
        },
      ),
    );

    await sync_.initListening();
  }

  void registrarDependencias() {
    Dependencias.registrar(
      (ILogger).toString(),
      () => Logger.instance,
    );
    Dependencias.registrar(
      (IAdaptadorDeBaseDeDatos).toString(),
      () => AdaptadorSQLite.instance,
    );
    Dependencias.registrar(
      (ISync).toString(),
      () => Sync.getInstance(),
    );
    Dependencias.registrar(
      (IAdaptadorDeTelemetria).toString(),
      () => AdaptadorDeTelemetria.instance,
    );
    Dependencias.registrar(
      (IAdaptadorDeDispositivo).toString(),
      () => AdaptadorDeDispositivo.instance,
    );
    Dependencias.registrar(
      (IRed).toString(),
      () => AdaptadorRed.instance,
    );
    Dependencias.registrar(
      (IRepositorioDeVentas).toString(),
      () => RepositorioVentas(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
      ),
    );
    Dependencias.registrar(
      (IRepositorioProductos).toString(),
      () => RepositorioProductos(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
      ),
    );
    Dependencias.registrar(
      (IRepositorioConsultaProductos).toString(),
      () => RepositorioConsultaProductos(
        db: Dependencias.infra.database(),
      ),
    );
  }

  Future<void> iniciarDB() async {
    adaptadorDB = Dependencias.infra.database();
    await adaptadorDB.conectar();

    var migrarDB = MigrarDB();
    await migrarDB.exec();
  }

  Future<void> enviarMetricasIniciales() async {
    var telemetria = ModuloTelemetria.enviarMetricasIniciales();

    await telemetria.exec();
  }

  Future<void> iniciar() async {
    WidgetsFlutterBinding.ensureInitialized();

    registrarDependencias();

    // Sistemas criticos:
    await appConfig.cargar();
    await iniciarLogging();
    await iniciarDB();
    await iniciarSync();

    await enviarMetricasIniciales();
    // Sistemas no criticos:
    // try {
    //   await enviarMetricasIniciales();
    // } catch (e) {

    // }
  }
}
