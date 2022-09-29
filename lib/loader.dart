import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/infra/logger.dart';
import 'package:eleventa/modulos/common/infra/adaptador_sqlite.dart';
import 'package:eleventa/modulos/common/infra/adaptador_telemetria.dart';
import 'package:eleventa/modulos/productos/app/interface/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_productos.dart';
import 'package:eleventa/modulos/migraciones/migrar_db.dart';
import 'package:eleventa/modulos/ventas/app/interface/adaptador_de_config_local.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/infra/adaptador_de_config_local.dart';
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
    var sync_ = Sync.create(
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
      ),
    );

    await sync_.initListening();
  }

  void registrarDependencias() {
    Dependencias.registrar((ILogger).toString(), () => Logger());
    Dependencias.registrar(
        (IAdaptadorDeBaseDeDatos).toString(), () => AdaptadorSQLite());
    Dependencias.registrar((ISync).toString(), () => Sync.get());
    Dependencias.registrar((IAdaptadorDeConfigLocalDeVentas).toString(),
        () => AdaptadorDeConfigLocalDeVentas());
    Dependencias.registrar(
        (IAdaptadorDeTelemetria).toString(), () => AdaptadorDeTelemetria());

    Dependencias.registrar(
      (IRepositorioDeVentas).toString(),
      () => RepositorioVentas(
        syncAdapter: Dependencias.infra.adaptadorSync(),
        db: Dependencias.infra.database(),
      ),
    );
    Dependencias.registrar(
      (IRepositorioArticulos).toString(),
      () => RepositorioProductos(
        syncAdapter: Dependencias.infra.adaptadorSync(),
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

  Future<void> iniciar() async {
    WidgetsFlutterBinding.ensureInitialized();

    registrarDependencias();
    await appConfig.cargar();

    await iniciarLogging();
    await iniciarDB();
    await iniciarSync();
  }
}
