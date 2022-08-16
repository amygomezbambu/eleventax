import 'dart:io';
import 'dart:math';

import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/migrations/migrate_db.dart';
import 'package:eleventa/modules/sync/sync.dart';
import 'package:eleventa/modules/sync/sync_config.dart';
import 'package:flutter/material.dart';

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class Loader {
  IDatabaseAdapter dbAdapter = Dependencies.infra.database();
  ILogger logger = Dependencies.infra.logger();

  /* #region Singleton */
  static final Loader _instance = Loader._internal();

  factory Loader() {
    return _instance;
  }

  Loader._internal();
  /* #endregion */

  Future<void> initLogging() async {
    var remoteLoggingLevels = [LoggerLevels.error];
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      remoteLoggingLevels = [];
    }

    //Inicializar Logger
    await logger.init(
      config: LoggerConfig(
        remoteLevels: remoteLoggingLevels,
        fileLevels: [LoggerLevels.error, LoggerLevels.warning],
        consoleLevels: [LoggerLevels.all],
      ),
    );
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    //Conectar adaptador de base de datos.
    await dbAdapter.connect();

    //2.- Cargar la configuracion
    await initLogging();

    //3.- Ejecutar Migraciones
    var migrateDB = MigrateDB();
    await migrateDB.exec();

    //Inicializar sincronizacion
    var randomGen = Random();

    var sync_ = Sync.create(
      syncConfig: SyncConfig.create(
          dbVersionTable: 'migrations',
          dbVersionField: 'version',
          groupId: 'CH0001',
          deviceId: randomGen.nextInt(1000).toString(),
          addChangesEndpoint:
              'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync',
          getChangesEndpoint:
              'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync-get-changes',
          deleteChangesEndpoint: 'http://localhost:3000/sync-delete-changes',
          pullInterval: 10000),
    );

    await sync_.initListening();
  }
}
