import 'package:eleventa/modules/common/error/error.dart';

abstract class ILogger {
  void info(String message);
  void warn(String message);
  void debug(String message);
  void error(EleventaError ex);
}
