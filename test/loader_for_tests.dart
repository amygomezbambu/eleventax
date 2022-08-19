import 'dart:math';

import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:eleventa/modules/common/infra/logger.dart';
import 'package:eleventa/modules/common/infra/sqlite_adapter.dart';
import 'package:eleventa/modules/config/config.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/infra/item_repository.dart';
import 'package:eleventa/modules/migrations/migrate_db.dart';
import 'package:eleventa/modules/sales/app/interface/sale_repository.dart';
import 'package:eleventa/modules/sales/infra/sale_repository.dart';
import 'package:eleventa/modules/sync/sync.dart';
import 'package:eleventa/modules/sync/sync_config.dart';
import 'package:flutter/material.dart';

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class TestsLoader {
  late IDatabaseAdapter dbAdapter;
  late ILogger logger;

  /* #region Singleton */
  static final TestsLoader _instance = TestsLoader._internal();

  factory TestsLoader() {
    return _instance;
  }

  TestsLoader._internal();
  /* #endregion */

  Future<void> initLogging() async {
    logger = Dependencies.infra.logger();

    await logger.init(
      config: LoggerConfig(
        remoteLevels: [],
        fileLevels: [],
        consoleLevels: [LoggerLevels.all],
      ),
    );
  }

  Future<void> initSync() async {
    Sync.create(
      syncConfig: SyncConfig.create(
        dbVersionTable: 'migrations',
        dbVersionField: 'version',
        groupId: 'CH0001',
        deviceId: Config.deviceId,
        addChangesEndpoint:
            'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync',
        getChangesEndpoint:
            'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync-get-changes',
        deleteChangesEndpoint: 'http://localhost:3000/sync-delete-changes',
        pullInterval: 10000,
        sendChangesInmediatly: false,
      ),
    );
  }

  void registerDependencies() {
    Dependencies.register((ILogger).toString(), () => Logger());
    Dependencies.register((IDatabaseAdapter).toString(), () => SQLiteAdapter());
    Dependencies.register((ISync).toString(), () => Sync.get());

    Dependencies.register(
      (ISaleRepository).toString(),
      () => SaleRepository(
        syncAdapter: Dependencies.infra.syncAdapter(),
        db: Dependencies.infra.database(),
      ),
    );
    Dependencies.register(
      (IItemRepository).toString(),
      () => ItemRepository(
        syncAdapter: Dependencies.infra.syncAdapter(),
        db: Dependencies.infra.database(),
      ),
    );
  }

  Future<void> initDatabase() async {
    dbAdapter = Dependencies.infra.database();
    await dbAdapter.connect();

    var migrateDB = MigrateDB();
    await migrateDB.exec();
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    //TODO: cambiarlo cuando tengamos config real
    Config.deviceId = Random().nextInt(1000).toString();
    Config.loggedUser = 'Alejandro Gamboa';

    registerDependencies();

    await initLogging();
    await initDatabase();
    await initSync();
  }
}
