import 'dart:io';

import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/db_utils.dart';
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

class AdaptadorSQLite implements IAdaptadorDeBaseDeDatos {
  late final Database _db;
  final _logger = Dependencias.infra.logger();
  late final String _carpetaBd;

  var _verbose = false;

  // Codigos de error que queremos detectar de SQLite
  // https://www.sqlite.org/rescode.html
  static const sqliteNotADbError = 26;

  /* #region Singleton */
  static final AdaptadorSQLite instance = AdaptadorSQLite._();

  AdaptadorSQLite._();
  /* #endregion */

  Future<void> desconectar() async {
    await _db.close();
  }

  static void _sqliteInit() {
    try {
      if (Platform.isAndroid) {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      } else if (Platform.isWindows || Platform.isLinux) {
        open.openSqlite();
      } else {
        open.overrideForAll(_sqlcipherOpen);
      }
    } catch (ex) {
      throw InfraEx(
        tipo: TipoInfraEx.errorInicializacionDB,
        message: 'No se pudo cargar SQLite ${ex.toString()}',
        innerException: ex,
      );
    }
  }

  bool _debugCheckHasCipher(Database database) {
    return database.rawQuery('PRAGMA cipher_version;').toString().isNotEmpty;
  }

  static DynamicLibrary _sqlcipherOpen() {
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    }

    throw UnsupportedError(
        'SQLite, plataforma no soportada: ${Platform.operatingSystem}');
  }

  @override
  Future<void> conectar({bool verbose = false}) async {
    _verbose = verbose;

    final DatabaseFactory dbFactory =
        createDatabaseFactoryFfi(ffiInit: _sqliteInit);

    var archivoBD = '';

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      archivoBD = inMemoryDatabasePath;
    } else {
      _carpetaBd = (await getApplicationDocumentsDirectory()).path;
      _logger.info('Carpeta BD: $_carpetaBd');
      archivoBD = join(_carpetaBd, 'eleventa.db');
    }

    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _logger.info('Conectando a BD en "$archivoBD"');
    }

    try {
      _db = await dbFactory.openDatabase(
        archivoBD,
        options: OpenDatabaseOptions(
            version: 1,
            onConfigure: (db) async {
              await db.rawQuery("PRAGMA KEY='${appConfig.secrets.dbPassword}'");
              // Verificamos que al preguntarle SQLite nos confirme que
              // estamos usando una conexion con SQLCipher
              assert(_debugCheckHasCipher(db));
            },
            onCreate: (db, version) async {
              if (!Platform.environment.containsKey('FLUTTER_TEST')) {
                _logger.info(
                    'No hay base de datos, creando con user version ${version.toString()}');
              }
            }),
      );

      // Logeamos las versiones usadas
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
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
            _logger.warn(EleventaEx(
              message: '-- Sin soporte para SQLCipher ---',
              tipo_: TipoEleventaEx.errorGenerico,
            ));
          }
        });
      }
    } catch (ex) {
      if (ex is SqfliteFfiException) {
        if (ex.getResultCode() == AdaptadorSQLite.sqliteNotADbError) {
          debugPrint('------------------------------------------');
          debugPrint(
              '** CONTRASEÑA INCORRECTA, ARCHIVO DE BD CORRUPTO O NO ENCRIPTADO **');
          debugPrint('------------------------------------------');
        } else {
          debugPrint(ex.toString());
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
    try {
      if (params != null) {
        if (_verbose) {
          _logger.debug(message: '[SQL] $sql [PARAMS] $params');
        }
        await _db.rawQuery(sql, _sanitizarParams(params));
      } else {
        if (_verbose) {
          _logger.debug(message: '[SQL] $sql');
        }
        await _db.rawQuery(sql);
      }
    } catch (e, stack) {
      throw InfraEx(
        tipo: TipoInfraEx.errorConsultaDB,
        message: 'Ocurrió un error al enviar un comando a la base de datos $e',
        innerException: e,
        stackTrace: stack,
        input: '[SQL] $sql [PARAMS] $params',
      );
    }
  }

  List<Object?> _sanitizarParams(List<Object?> params) {
    List<Object?> nuevosParams = [];
    for (var param in params) {
      if (param is bool) {
        nuevosParams.add(DBUtils().boolToInt(param));
      } else {
        nuevosParams.add(param);
      }
    }

    return nuevosParams;
  }

  @override
  Future<List<Map<String, Object?>>> query({
    required String sql,
    List<Object?>? params,
  }) async {
    var result = <Map<String, Object?>>[];
    List<Map<String, Object?>>? dbResult;

    try {
      if (params != null) {
        if (_verbose) {
          _logger.debug(message: '[SQL] $sql [PARAMS] $params');
        }

        dbResult = await _db.rawQuery(sql, _sanitizarParams(params));
      } else {
        if (_verbose) {
          _logger.debug(message: '[SQL] $sql');
        }

        dbResult = await _db.rawQuery(sql);
      }

      if (dbResult.isNotEmpty) {
        result.addAll(dbResult);
      }
    } catch (e, stack) {
      throw InfraEx(
        tipo: TipoInfraEx.errorConsultaDB,
        message:
            'Ocurrió un error al consultar la base de datos ${e.toString()}',
        innerException: e,
        stackTrace: stack,
        input: '[SQL] $sql [PARAMS] $params',
      );
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

  @override
  set verbose(bool value) {
    _verbose = value;
  }
}
