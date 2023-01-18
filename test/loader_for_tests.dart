import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/telemetria/infra/repositorio_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/common/infra/logger.dart';
import 'package:eleventa/modulos/common/infra/adaptador_sqlite.dart';
import 'package:eleventa/modulos/notificaciones/infra/repositorio_notificaciones.dart';
import 'package:eleventa/modulos/notificaciones/interfaces/repositorio_notificaciones.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_productos.dart';
import 'package:eleventa/modulos/migraciones/migrar_db.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/ventas/infra/repositorio_consultas_ventas.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:eleventa/modulos/telemetria/infra/adaptador_telemetria.dart';
import 'package:eleventa/modulos/ventas/infra/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes/adaptador_dispositivo.dart';
import 'fakes/adaptador_red.dart';

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class TestsLoader {
  late IAdaptadorDeBaseDeDatos dbAdapter;
  late ILogger logger;

  /* #region Singleton */
  static final TestsLoader _instance = TestsLoader._internal();

  factory TestsLoader() {
    return _instance;
  }

  TestsLoader._internal();
  /* #endregion */

  Future<void> iniciarLogging() async {
    logger = Dependencias.infra.logger();

    await logger.iniciar(
      config: LoggerConfig(
        nivelesRemotos: [],
        nivelesDeArchivo: [],
        nivelesDeConsola: [NivelDeLog.all],
      ),
    );
  }

  Future<void> iniciarSync() async {
    Sync(
      config: SyncConfig(
          dbVersionTable: 'migrations',
          dbVersionField: 'version',
          groupId: 'CH0001',
          deviceId: appConfig.deviceId.toString(),
          addChangesEndpoint: 'http://localhost:3000/sync',
          getChangesEndpoint: 'http://localhost:3000/sync',
          deleteChangesEndpoint: 'http://localhost:3000/sync-delete-changes',
          pullInterval: 10000,
          sendChangesInmediatly: false,
          onError: (ex, stack) {
            Dependencias.infra.logger().error(ex: ex, stackTrace: stack);
            throw ex;
          }),
    );
  }

  void registrarDependencias() {
    Dependencias.registrar((ILogger).toString(), () => Logger.instance);
    Dependencias.registrar(
        (IAdaptadorDeBaseDeDatos).toString(), () => AdaptadorSQLite.instance);
    Dependencias.registrar((ISync).toString(), () => Sync.getInstance());
    Dependencias.registrar((IAdaptadorDeTelemetria).toString(),
        () => AdaptadorDeTelemetria.instance);
    Dependencias.registrar(
        (IAdaptadorDeDispositivo).toString(), () => AdaptadorDispositivoFake());
    Dependencias.registrar((IRed).toString(), () => AdaptadorRedFake());

    Dependencias.registrar(
      (IRepositorioConsultaVentas).toString(),
      () => RepositorioConsultaVentas(
        db: Dependencias.infra.database(),
        logger: Dependencias.infra.logger(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioVentas).toString(),
      () => RepositorioVentas(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
        consultas: Dependencias.ventas.repositorioConsultasVentas(),
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
        logger: Dependencias.infra.logger(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioNotificaciones).toString(),
      () => RepositorioNotificaciones(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioTelemetria).toString(),
      () => RepositorioTelemetria(
        Dependencias.infra.sync(),
        Dependencias.infra.database(),
      ),
    );
  }

  Future<void> iniciarDB() async {
    dbAdapter = Dependencias.infra.database();
    await dbAdapter.conectar(verbose: logger.logeoParaPruebasActivo);

    var migrateDB = MigrarDB();
    await migrateDB.exec();
  }

  Future<void> iniciar() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await appConfig.cargar();

    registrarDependencias();

    await iniciarLogging();
    await iniciarDB();
    await iniciarSync();
  }
}
