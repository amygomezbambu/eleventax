import 'package:eleventa/modules/common/error/error.dart';

abstract class ILogger {
  /// Metodo que inicializa el logger
  ///
  /// Debe ser llamado antes de utilizar cualquier metodo de logeo
  Future<void> init();
  void info(String message);
  void warn(String message);
  void debug(String message);
  void error(EleventaError ex);
}
