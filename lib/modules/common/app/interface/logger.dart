import 'package:eleventa/modules/common/exception/exception.dart';

///Buenas practicas:
///1.Generar el log en JSON u otro formato que se pueda manejar mas facil que el texto plano
///2.Agregar contexto, dispositivo, usuario, request, caso de uso, si es una falla de infraestructura
///por ejemplo la db, agregar tamaño de la db y otras metricas que ayuden a saber si hay algo
///riesgoso (por ejemplo si es una db gigante)
///3.Write meaningfull log messages(and meaningfull errors)
class LogEntry {
  var timestamp = 0;
  var userId = '';
  var deviceId = '';
  String? input = '';
  var message = '';
  Object? exception;
  StackTrace? stackTrace;
}

enum LoggerLevels { info, debug, error, warning, all }

class LoggerConfig {
  var remoteLevels = <LoggerLevels>[];
  var fileLevels = <LoggerLevels>[];
  var consoleLevels = <LoggerLevels>[];
  var fileMaxSizeInMB = 1000;

  LoggerConfig(
      {required this.remoteLevels,
      required this.fileLevels,
      required this.consoleLevels,
      this.fileMaxSizeInMB = 1000});
}

abstract class ILogger {
  /// Metodo que inicializa el logger
  ///
  /// Debe ser llamado antes de utilizar cualquier metodo de logeo
  Future<void> init({required LoggerConfig config});
  void info(String message);

  /// Logea un warning
  ///
  /// recibe [EleventaException] debido a que un warn siempre se lanza manualmente
  void warn(EleventaException ex);
  void debug({required String message, Exception? ex, StackTrace? stackTrace});
  void error({required Object ex, StackTrace? stackTrace});
}
