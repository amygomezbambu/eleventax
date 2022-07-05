import 'dart:io';

import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

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

  @override
  Future<void> connect() async {
    String dbPath = '';

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      dbPath = inMemoryDatabasePath;
      databaseFactory = databaseFactoryFfi;
    } else {
      dbPath = (await getApplicationDocumentsDirectory()).path;
      dbPath = join(dbPath, 'eleventa.db');
      print('Conectado a BD: $dbPath'); //prueba
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      databaseFactory = databaseFactoryFfi;
    }

    _db = await openDatabase(dbPath);
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
