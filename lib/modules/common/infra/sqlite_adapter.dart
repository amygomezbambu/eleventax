import 'dart:io';

import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi/src/sqflite_ffi_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'dart:ffi';
import 'package:eleventa/modules/common/infra/environment.dart';

class SQLiteAdapter implements IDatabaseAdapter {
  Database? _db;
  @protected
  late final ILogger logger;

  /* #region Singleton */
  static final SQLiteAdapter _instance = SQLiteAdapter._internal();

  factory SQLiteAdapter() {
    return _instance;
  }

  SQLiteAdapter._internal();
  /* #endregion */

  Future<void> disconnect() async {
    await _db?.close();
  }

  void _sqliteInit() {
    if (Platform.isAndroid) {
      open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    }

    if (Platform.isWindows) {
      // Para Windows hacemos uso de la funcion especial
      // proveida por "sqlcipher_library_windows"
      open.overrideFor(OperatingSystem.windows, openSQLCipherOnWindows);
    } else {
      open.overrideForAll(_sqlcipherOpen);
    }
  }

  bool _debugCheckHasCipher(Database database) {
    return database.rawQuery('PRAGMA cipher_version;').toString().isNotEmpty;
  }

  DynamicLibrary _sqlcipherOpen() {
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    }

    throw UnsupportedError(
        'SQLite, plataforma no soportada: ${Platform.operatingSystem}');
  }

  @override
  Future<void> connect() async {
    // logger = Dependencies.infra.logger();
    String dbPath = '';

    final DatabaseFactory dbFactory =
        createDatabaseFactoryFfi(ffiInit: _sqliteInit);

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dbPath = inMemoryDatabasePath;
      // logger.info('Conectando a BD en <MEMORIA>');
    } else {
      // dbPath = (await getApplicationDocumentsDirectory()).path;
      // dbPath = join(dbPath, 'eleventa.db');

      dbPath = inMemoryDatabasePath;
      // logger.info('Conectando a BD en "$dbPath"');
    }

    try {
      _db = await dbFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
            version: 1,
            onConfigure: (db) async {
              await db.rawQuery("PRAGMA KEY='${Environment.databasePassword}'");
              // Verificamos que al preguntarle SQLite nos confirme que
              // estamos usando una conexion con SQLCipher
              assert(_debugCheckHasCipher(db));
            },
            onCreate: (db, version) async {
              // logger.info(
              // 'No hay base de datos, creando con user version ${version.toString()}');
            }),
      );

      // Logeamos las versiones usadas
      if (_db != null) {
        await _db!.rawQuery("SELECT sqlite_version()").then((result) {
          // logger.info('SQLite v${value.toString()}');
          debugPrint('SQLite v${result.first.values.first}');
        });

        // Mostramos la versión de la base de datos (user version)
        _db!.getVersion().then((value) => {
              // logger.info('Database Version: ${value.toString()}');
              debugPrint('Database Version: ${value.toString()}')
            });

        await _db!.rawQuery("PRAGMA cipher_version").then((result) {
          // logger.info('SQLCipher version: ${value.toString()}');
          debugPrint('SQLCipher version: ${result.first.values.first}');
        });
      }
    } catch (ex, stack) {
      //logger.error(ex: ex as Exception, stackTrace: stack);
      debugPrint('------------------------------------------');
      if (ex is SqfliteFfiException) {
        if (ex.getResultCode() == 26) {
          debugPrint(
              '** CONTRASEÑA INCORRECTA, ARCHIVO DE BD CORRUPTO O NO ENCRIPTADO **');
        } else {
          debugPrint(ex.toString());
        }
      }
      debugPrint('------------------------------------------');
      rethrow;
    }
  }

  @override
  Future<void> command({required String sql, List<Object>? params}) async {
    if (params != null) {
      await _db?.execute(sql, params);
    } else {
      await _db?.execute(sql);
    }
  }

  @override
  Future<List<Map<String, Object?>>> query(
      {required String sql, List<Object>? params}) async {
    var result = <Map<String, Object?>>[];
    List<Map<String, Object?>>? dbResult;

    if (params != null) {
      dbResult = await _db?.rawQuery(sql, params);
    } else {
      dbResult = await _db?.rawQuery(sql);
    }

    if (dbResult != null) {
      result.addAll(dbResult);
    }

    return result;
  }

  @override
  Future<void> commit() async {
    await command(sql: 'COMMIT');
  }

  @override
  Future<void> rollback() async {
    await command(sql: 'ROLLBACK');
  }

  @override
  Future<void> transaction() async {
    await command(sql: 'BEGIN TRANSACTION');
  }
}
