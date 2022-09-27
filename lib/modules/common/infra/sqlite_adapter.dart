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
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'dart:ffi';
import 'package:eleventa/modules/common/infra/environment.dart';

class SQLiteAdapter implements IDatabaseAdapter {
  late final Database _db;
  final _logger = Dependencies.infra.logger();

  var _verbose = false;

  // Librerias de las que se depende en Windows
  static const libcryptoWindowsLibrary = 'libcrypto-1_1-x64.dll';
  static const sslWindowsLibrary = 'libssl-1_1-x64.dll';
  static const sqlcipherWindowsLibrary = 'sqlcipher.dll';

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

  /// Lee la libreria de SQLite en Windows
  ///
  /// Se encarga de especificar la ruta de la libreria de SQLite
  /// la cual debe estar presente en la carpeta donde esta el ejecutable
  /// también es necesaria la prescencia de los archivos:
  /// sqlcipher.dll, libcrypto-1_1-x64.dll, libssl-1_1-x64.dll
  ///
  /// Esta función y DLLs fueron tomados del paquete:
  /// https://github.com/MobiliteDev/sqlcipher_library_windows
  static DynamicLibrary _openSQLCipherOnWindows() {
    late DynamicLibrary library;

    // Verificamos que existan las librerias que necesitamos
    if (!File(SQLiteAdapter.libcryptoWindowsLibrary).existsSync()) {
      debugPrint(
          'No existe libreria requerida: $SQLiteAdapter.libcryptoWindowsLibrary');
    }

    if (!File(SQLiteAdapter.sslWindowsLibrary).existsSync()) {
      debugPrint(
          'No existe libreria requerida: $SQLiteAdapter.sslWindowsLibrary');
    }

    if (!File(SQLiteAdapter.sqlcipherWindowsLibrary).existsSync()) {
      debugPrint(
          'No existe libreria requerida: $SQLiteAdapter.sqlcipherWindowsLibrary');
    }

    library = DynamicLibrary.open(SQLiteAdapter.sqlcipherWindowsLibrary);

    return library;
  }

  static void _sqliteInit() {
    try {
      if (Platform.isAndroid) {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      }

      if (Platform.isWindows) {
        open.overrideFor(OperatingSystem.windows, _openSQLCipherOnWindows);
      } else {
        open.overrideForAll(_sqlcipherOpen);
      }
    } catch (ex) {
      throw InfrastructureException(
          message: 'No se pudo cargar SQLite ${ex.toString()}',
          innerException: ex);
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
  Future<void> connect({bool verbose = false}) async {
    _verbose = verbose;
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
      await _db.getVersion().then(
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
    if (params != null) {
      if (_verbose) {
        _logger.debug(message: '[SQL] $sql [PARAMS] $params');
      }
      await _db.execute(sql, params);
    } else {
      if (_verbose) {
        _logger.debug(message: '[SQL] $sql');
      }
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
      if (_verbose) {
        _logger.debug(message: '[SQL] $sql [PARAMS] $params');
      }

      dbResult = await _db.rawQuery(sql, params);
    } else {
      if (_verbose) {
        _logger.debug(message: '[SQL] $sql');
      }

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
