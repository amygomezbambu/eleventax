import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as log;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

class Logger implements ILogger {
  final _logger = log.Logger('Main');
  late LoggerOptions _options;

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
  Future<void> captureException(error, stackTrace) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> init({required LoggerOptions options}) async {
    _options = options;

    await SentryFlutter.init(
      (options) {
        // TODO: Sacar el DSN a variable de entorno
        options.dsn =
            'https://6a10edb2c5694e23a193d9feddc8df5e@o76265.ingest.sentry.io/6635342';
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;

        // Agregamos soporte para logeo via Sentry
        options.addIntegration(
          LoggingIntegration(
              minBreadcrumbLevel: log.Level.INFO,
              minEventLevel: log.Level.INFO),
        );
      },
    );

    // or define SENTRY_DSN via Dart environment variable (--dart-define)
  }

  @override
  void debug(String message) {
    _logger.fine(message);
  }

  @override
  void error(Exception ex) {
    if (ex is EleventaException) {
      _logger.severe(ex.message, ex.innerException, ex.stackTrace);
    } else {
      _logger.severe(ex.toString(), ex);
    }
  }

  @override
  void info(String message) async {
    if (_options.remoteLevels.contains(LoggerLevels.info) ||
        _options.remoteLevels.contains(LoggerLevels.all)) {
      await Sentry.captureMessage(message);
    }

    if (_options.consoleLevels.contains(LoggerLevels.info) ||
        _options.consoleLevels.contains(LoggerLevels.all)) {
      debugPrint(message);
    }

    if (_options.fileLevels.contains(LoggerLevels.info) ||
        _options.fileLevels.contains(LoggerLevels.all)) {
      _addLogTofile(message);
    }
  }

  @override
  void warn(String message) {
    _logger.warning(message);
  }

  void _addLogTofile(String message) {}
}
