import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart' as log;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sentry_logging/sentry_logging.dart';

class Logger implements ILogger {
  final _logger = log.Logger('Main');

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
  Future<void> init() async {
    await SentryFlutter.init(
      (options) {
        // ToDO: Sacar el DSN a variable de entorno
        options.dsn =
            'https://6a10edb2c5694e23a193d9feddc8df5e@o76265.ingest.sentry.io/6635342';
        // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
        // We recommend adjusting this value in production.
        options.tracesSampleRate = 1.0;

        // Agregamos soporte para logeo via Sentry
        options.addIntegration(LoggingIntegration());
      },
    );

    // or define SENTRY_DSN via Dart environment variable (--dart-define)
  }

  @override
  void debug(String message) {
    _logger.fine(message);
  }

  @override
  void error(EleventaException ex) {
    _logger.severe(ex.message, ex, ex.stackTrace);
  }

  @override
  void info(String message) {
    _logger.info(message);
  }

  @override
  void warn(String message) {
    _logger.warning(message);
  }
}
