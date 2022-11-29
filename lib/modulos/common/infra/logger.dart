import 'dart:async';
import 'dart:io';

import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as log;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path_provider/path_provider.dart';

class Logger implements ILogger {
  var _logeoParaPruebasActivo = false;

  @override
  bool get logeoParaPruebasActivo => _logeoParaPruebasActivo;

  final _logger = log.Logger('Main');
  late LoggerConfig _config;

  /* #region Singleton */
  static final Logger instance = Logger._();

  Logger._() {
    log.Logger.root.level = log.Level.ALL;

    log.Logger.root.onRecord.listen((rec) {
      if (rec.level == log.Level.SEVERE) {
        if (_logeoParaPruebasActivo) {
          debugPrint('\x1B[31m${rec.level.name}: ${rec.message}');
        } else {
          var msg = '\x1B[31m${rec.level.name}: ${rec.message} \n';
          msg += rec.error != null ? '[INNER EX]: ${rec.error} \n' : '';
          msg += rec.stackTrace != null ? '[STACK]: ${rec.stackTrace} \n' : '';
          msg += '\x1B[0m';

          debugPrint(msg);
        }
        return;
      }

      if (rec.level == log.Level.WARNING) {
        debugPrint(
            '\x1B[33m${rec.level.name}: ${rec.time}: ${rec.message}\x1B[0m');
        return;
      }

      if (rec.level == log.Level.INFO) {
        debugPrint(
            '\x1B[36m${rec.level.name}: ${rec.time}: ${rec.message}\x1B[0m');
        return;
      }

      debugPrint('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }
  /* #endregion */

  @override
  Future<void> iniciar({required LoggerConfig config}) async {
    _config = config;

    if (config.nivelesRemotos.isNotEmpty) {
      await SentryFlutter.init(
        (options) {
          options.dsn = appConfig.secrets.tokenLoggingRemoto;
          options.tracesSampleRate = 1.0;
          options.beforeSend = _beforeRemoteSend;
        },
      );
    }
  }

  @override
  void debug(
      {required String message, Exception? ex, StackTrace? stackTrace}) async {
    var logEntry = EntradaDeLog();
    logEntry.message = message;
    logEntry.exception = ex;
    logEntry.stackTrace = stackTrace;

    await _handleException(entry: logEntry, level: NivelDeLog.debug);
  }

  @override
  void error({required Object ex, StackTrace? stackTrace}) async {
    var logEntry = EntradaDeLog();

    logEntry.deviceId = appConfig.deviceId.toString();
    logEntry.userId = appConfig.usuarioLogeado;

    if (ex is EleventaEx) {
      logEntry.exception = ex.innerException;
      logEntry.stackTrace = ex.stackTrace;
      logEntry.message = ex.message;
      logEntry.input = ex.input;

      await _handleException(entry: logEntry, level: NivelDeLog.error);
    } else {
      logEntry.exception = ex;
      logEntry.stackTrace = stackTrace;
      logEntry.message = '';

      await _handleException(entry: logEntry, level: NivelDeLog.error);
    }
  }

  @override
  void info(String message) async {
    var logEntry = EntradaDeLog();
    logEntry.message = message;

    await _handleException(entry: logEntry, level: NivelDeLog.info);
  }

  @override
  void warn(EleventaEx ex) async {
    var logEntry = EntradaDeLog();
    logEntry.message = ex.message;
    logEntry.exception = ex;
    logEntry.stackTrace = ex.stackTrace;

    await _handleException(entry: logEntry, level: NivelDeLog.warning);
  }

  Future<void> _handleException({
    required EntradaDeLog entry,
    required NivelDeLog level,
  }) async {
    if (_config.nivelesRemotos.contains(level) ||
        _config.nivelesRemotos.contains(NivelDeLog.all)) {
      final eleventaContext = {
        'input': entry.input,
        'user': entry.userId,
        'device': entry.deviceId,
      };
      Sentry.configureScope(
          (scope) => scope.setContexts('eleventa_Context', eleventaContext));

      await Sentry.captureException(entry.exception,
          stackTrace: entry.stackTrace);
    }

    if (_config.nivelesDeConsola.contains(level) ||
        _config.nivelesDeConsola.contains(NivelDeLog.all)) {
      _printCosoleLog(entry, level);
    }

    if (_config.nivelesDeArchivo.contains(level) ||
        _config.nivelesDeArchivo.contains(NivelDeLog.all)) {
      await _addLogTofile(entry, level);
    }
  }

  void _printCosoleLog(EntradaDeLog entry, NivelDeLog level) {
    switch (level) {
      case NivelDeLog.debug:
        _logger.fine(entry.message, entry.exception, entry.stackTrace);
        break;
      case NivelDeLog.error:
        var message = entry.message;
        message += entry.input != null ? '\n[INPUT]:${entry.input}' : '';
        _logger.severe(message, entry.exception, entry.stackTrace);
        break;
      case NivelDeLog.info:
        _logger.info(entry.message);
        break;
      case NivelDeLog.warning:
        _logger.warning(entry.message, entry.exception, entry.stackTrace);
        break;
      default:
        _logger.fine(entry.message, entry.exception, entry.stackTrace);
    }
  }

  Future<void> _addLogTofile(EntradaDeLog entry, NivelDeLog level) async {
    var path = (await getApplicationSupportDirectory()).path;
    _logger.info('$path/eleventa.log');

    var file = File('$path/eleventa.log');
    var levelName = '';

    switch (level) {
      case NivelDeLog.debug:
        levelName = 'DEBUG';
        break;
      case NivelDeLog.error:
        levelName = 'ERROR';
        break;
      case NivelDeLog.info:
        levelName = 'INFO';
        break;
      case NivelDeLog.warning:
        levelName = 'WARNING';
        break;
      default:
    }

    final content = '$levelName: ${DateTime.now().toUtc()}: ${entry.message}\n'
        '${entry.exception.toString()}\n'
        '${entry.stackTrace}\n'
        '_________________________________________________\n';

    await file.writeAsString(content, mode: FileMode.append);
  }

  FutureOr<SentryEvent?> _beforeRemoteSend(SentryEvent event,
      {dynamic hint}) async {
    var contexts = Contexts(
        device: event.contexts.device,
        operatingSystem: event.contexts.operatingSystem);

    var modifiedEvent = SentryEvent(
      breadcrumbs: event.breadcrumbs,
      contexts: contexts,
      culprit: event.culprit,
      dist: event.dist,
      environment: event.environment,
      eventId: event.eventId,
      exceptions: event.exceptions,
      extra: event.extra,
      fingerprint: event.fingerprint,
      level: event.level,
      logger: event.logger,
      message: event.message,
      platform: event.platform,
      request: event.request,
      tags: event.tags,
      throwable: event.throwable,
      timestamp: event.timestamp,
      transaction: event.transaction,
      type: event.type,
      user: event.user,
    );

    return modifiedEvent;
  }

  @override
  void activarLogeoParaPruebas(bool activo) {
    _logeoParaPruebasActivo = activo;
  }
}
