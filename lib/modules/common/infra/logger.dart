import 'dart:async';
import 'dart:io';

import 'package:eleventa/globals.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as log;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:path_provider/path_provider.dart';

class Logger implements ILogger {
  final _logger = log.Logger('Main');
  late LoggerConfig _config;

  /* #region Singleton */
  static final Logger _instance = Logger._internal();

  factory Logger() {
    return _instance;
  }

  Logger._internal() {
    log.Logger.root.level = log.Level.ALL;

    log.Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }
  /* #endregion */

  @override
  Future<void> init({required LoggerConfig config}) async {
    _config = config;

    if (config.remoteLevels.isNotEmpty) {
      await SentryFlutter.init(
        (options) {
          // TODO: Sacar el DSN a variable de entorno
          options.dsn =
              'https://6a10edb2c5694e23a193d9feddc8df5e@o76265.ingest.sentry.io/6635342';
          options.tracesSampleRate = 1.0;
          options.beforeSend = _beforeRemoteSend;
        },
      );
    }

    // or define SENTRY_DSN via Dart environment variable (--dart-define)
  }

  @override
  void debug(
      {required String message, Exception? ex, StackTrace? stackTrace}) async {
    var logEntry = LogEntry();
    logEntry.message = message;
    logEntry.exception = ex;
    logEntry.stackTrace = stackTrace;

    await _handleException(entry: logEntry, level: LoggerLevels.debug);
  }

  @override
  void error({required Object ex, StackTrace? stackTrace}) async {
    var logEntry = LogEntry();

    logEntry.deviceId = appConfig.deviceId.toString();
    logEntry.userId = appConfig.loggedUser;

    if (ex is EleventaException) {
      logEntry.exception = ex;
      logEntry.stackTrace = ex.stackTrace;
      logEntry.message = ex.message;
      logEntry.input = ex.input;

      await _handleException(entry: logEntry, level: LoggerLevels.error);
    } else {
      logEntry.exception = ex;
      logEntry.stackTrace = stackTrace;
      logEntry.message = '';

      await _handleException(entry: logEntry, level: LoggerLevels.error);
    }
  }

  @override
  void info(String message) async {
    var logEntry = LogEntry();
    logEntry.message = message;

    await _handleException(entry: logEntry, level: LoggerLevels.info);
  }

  @override
  void warn(EleventaException ex) async {
    var logEntry = LogEntry();
    logEntry.message = ex.message;
    logEntry.exception = ex;
    logEntry.stackTrace = ex.stackTrace;

    await _handleException(entry: logEntry, level: LoggerLevels.warning);
  }

  Future<void> _handleException({
    required LogEntry entry,
    required LoggerLevels level,
  }) async {
    if (_config.remoteLevels.contains(level) ||
        _config.remoteLevels.contains(LoggerLevels.all)) {
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

    if (_config.consoleLevels.contains(level) ||
        _config.consoleLevels.contains(LoggerLevels.all)) {
      _printCosoleLog(entry, level);
    }

    if (_config.fileLevels.contains(level) ||
        _config.fileLevels.contains(LoggerLevels.all)) {
      await _addLogTofile(entry, level);
    }
  }

  void _printCosoleLog(LogEntry entry, LoggerLevels level) {
    switch (level) {
      case LoggerLevels.debug:
        _logger.fine(entry.message, entry.exception, entry.stackTrace);
        break;
      case LoggerLevels.error:
        _logger.severe(entry.message, entry.exception, entry.stackTrace);
        break;
      case LoggerLevels.info:
        _logger.info(entry.message);
        break;
      case LoggerLevels.warning:
        _logger.warning(entry.message, entry.exception, entry.stackTrace);
        break;
      default:
        _logger.fine(entry.message, entry.exception, entry.stackTrace);
    }
  }

  Future<void> _addLogTofile(LogEntry entry, LoggerLevels level) async {
    var path = (await getApplicationSupportDirectory()).path;
    _logger.info('$path/eleventa.log');

    var file = File('$path/eleventa.log');
    var levelName = '';

    switch (level) {
      case LoggerLevels.debug:
        levelName = 'DEBUG';
        break;
      case LoggerLevels.error:
        levelName = 'ERROR';
        break;
      case LoggerLevels.info:
        levelName = 'INFO';
        break;
      case LoggerLevels.warning:
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
}
