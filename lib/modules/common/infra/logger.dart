import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/error/error.dart';
import 'package:flutter/material.dart';

class Logger implements ILogger {
  /* #region Singleton */
  static final Logger _instance = Logger._internal();

  factory Logger() {
    return _instance;
  }

  Logger._internal();
  /* #endregion */

  @override
  void debug(String message) {
    debugPrint('DEBUG: ' + message);
  }

  @override
  void error(EleventaError ex) {
    debugPrint('ERROR: ' + ex.message);
  }

  @override
  void info(String message) {
    debugPrint('INFO: ' + message);
  }

  @override
  void warn(String message) {
    debugPrint('WARN: ' + message);
  }
}
