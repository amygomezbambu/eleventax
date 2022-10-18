import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/infra/logger.dart';
import 'package:eleventa/modulos/common/infra/adaptador_sqlite.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_productos.dart';
import 'package:eleventa/modulos/migraciones/migrar_db.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/infra/repositorio_ventas.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:eleventa/modulos/common/infra/adaptador_telemetria.dart';
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
    Sync.init(
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
        sendChangesInmediatly: false,
        onError: (ex, stack) =>
            Dependencias.infra.logger().error(ex: ex, stackTrace: stack),
      ),
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
      (IRepositorioDeVentas).toString(),
      () => RepositorioVentas(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
      ),
    );
    Dependencias.registrar(
      (IRepositorioArticulos).toString(),
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
  }

  Future<void> iniciarDB() async {
    dbAdapter = Dependencias.infra.database();
    await dbAdapter.conectar();

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
