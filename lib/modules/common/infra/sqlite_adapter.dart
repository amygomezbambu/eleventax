import 'dart:io';

import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqlcipher_library_windows/sqlcipher_library_windows.dart';
import 'package:sqlite3/open.dart';
import 'dart:ffi';
import 'dart:math';
import 'environment.dart';

class SQLiteAdapter implements IDatabaseAdapter {
  Database? _db;

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
    // Basado en https://github.com/simolus3/sqlite3.dart/blob/e66702c5bec7faec2bf71d374c008d5273ef2b3b/sqlite3/lib/src/load_library.dart#L24
    if (Platform.isLinux || Platform.isAndroid) {
      try {
        // Leemos nuestra propia libreria embebida con soporte para SQLCipher
        return DynamicLibrary.open('libsqlcipher.so');
      } catch (_) {
        if (Platform.isAndroid) {
          // On some (especially old) Android devices, we somehow can't dlopen
          // libraries shipped with the apk. We need to find the full path of the
          // library (/data/data/<id>/lib/libsqlite3.so) and open that one.
          // For details, see https://github.com/simolus3/moor/issues/420
          final appIdAsBytes = File('/proc/self/cmdline').readAsBytesSync();

          // app id ends with the first \0 character in here.
          final endOfAppId = max(appIdAsBytes.indexOf(0), 0);
          final appId =
              String.fromCharCodes(appIdAsBytes.sublist(0, endOfAppId));

          return DynamicLibrary.open('/data/data/$appId/lib/libsqlcipher.so');
        }

        rethrow;
      }
    }

    if (Platform.isIOS || Platform.isMacOS) {
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

    if (Platform.environment.containsKey('FLUTTER_TEST1') &&
        !Platform.environment.containsKey('PERFORMANCE_TEST')) {
      dbPath = inMemoryDatabasePath;
      debugPrint('Conectado a BD: MEMORIA');
    } else {
      dbPath = (await getApplicationDocumentsDirectory()).path;
      dbPath = join(dbPath, 'eleventa-enc6.db');
      debugPrint('Conectado a BD: $dbPath');
    }

    debugPrint("PRAGMA KEY='${Environment.databasePassword}'");

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
          debugPrint(
              'No hay base de datos, crenado con user version ${version.toString()}');
        },
      ),
    );

    if (_db != null) {
      _db!.getVersion().then((value) => {debugPrint(value.toString())});
      await _db!.rawQuery("PRAGMA cipher_version").then((value) {
        debugPrint(value.toString());
      });
      //print(await _db!.rawQuery("SELECT * FROM sqlite_master"));
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
