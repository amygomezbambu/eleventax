import 'dart:io';

import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: implementation_imports
import 'package:sqflite_common_ffi/src/sqflite_ffi_exception.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'dart:ffi';
import 'package:eleventa/modules/common/infra/environment.dart';

class SQLiteAdapter implements IDatabaseAdapter {
  late final Database _db;
  final _logger = Dependencies.infra.logger();
  // Codigos de error que queremos detectar de SQLite
  // https://www.sqlite.org/rescode.html
  static const sqliteNotADbError = 26;

  /* #region Singleton */
  static final SQLiteAdapter _instance = SQLiteAdapter._internal();

  factory SQLiteAdapter() {
    return _instance;
  }

  SQLiteAdapter._internal();
  /* #endregion */

  Future<void> disconnect() async {
    await _db.close();
  }

  static void _sqliteInit() {
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

  static DynamicLibrary _sqlcipherOpen() {
    if (Platform.isIOS || Platform.isMacOS || Platform.isLinux) {
      return DynamicLibrary.process();
    }

    throw UnsupportedError(
        'SQLite, plataforma no soportada: ${Platform.operatingSystem}');
  }

  @override
  Future<void> connect() async {
    String dbPath = '';

    final DatabaseFactory dbFactory =
        createDatabaseFactoryFfi(ffiInit: _sqliteInit);

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dbPath = inMemoryDatabasePath;
    } else {
      dbPath = (await getApplicationDocumentsDirectory()).path;
      dbPath = join(dbPath, 'eleventa.db');
    }

    _logger.info('Conectando a BD en "$dbPath"');

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
              _logger.info(
                  'No hay base de datos, creando con user version ${version.toString()}');
            }),
      );

      // Logeamos las versiones usadas
      await _db.rawQuery("SELECT sqlite_version()").then((result) {
        _logger.info('SQLite v${result.first.values.first}');
      });

      // Mostramos la versión de la base de datos (user version)
      _db.getVersion().then(
          (value) => {_logger.info('Database Version: ${value.toString()}')});

      await _db.rawQuery("PRAGMA cipher_version").then((result) {
        if (result.isNotEmpty) {
          _logger.info('SQLCipher v${result.first.values.first}');
        } else {
          _logger.warn(
              EleventaException(message: '-- Sin soporte para SQLCipher ---'));
        }
      });
    } catch (ex) {
      if (ex is SqfliteFfiException) {
        if (ex.getResultCode() == SQLiteAdapter.sqliteNotADbError) {
          debugPrint('------------------------------------------');
          debugPrint(
              '** CONTRASEÑA INCORRECTA, ARCHIVO DE BD CORRUPTO O NO ENCRIPTADO **');
          debugPrint('------------------------------------------');
        }
      }

      rethrow;
    }
  }

  @override
  Future<void> command({
    required String sql,
    List<Object?>? params,
  }) async {
    _logger.debug(message: '[SQL] $sql [PARAMS] $params');
    if (params != null) {
      await _db.execute(sql, params);
    } else {
      await _db.execute(sql);
    }
  }

  @override
  Future<List<Map<String, Object?>>> query({
    required String sql,
    List<Object?>? params,
  }) async {
    var result = <Map<String, Object?>>[];
    List<Map<String, Object?>>? dbResult;

    if (params != null) {
      dbResult = await _db.rawQuery(sql, params);
    } else {
      dbResult = await _db.rawQuery(sql);
    }

    if (dbResult.isNotEmpty) {
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
