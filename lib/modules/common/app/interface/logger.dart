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
  var useCaseRequest = '';
}

enum LoggerLevels { info, debug, error, warning, all }

class LoggerOptions {
  var remoteLevels = <LoggerLevels>[];
  var fileLevels = <LoggerLevels>[];
  var consoleLevels = <LoggerLevels>[];
  var fileMaxSizeInMB = 1000;

  LoggerOptions(
      {required this.remoteLevels,
      required this.fileLevels,
      required this.consoleLevels,
      this.fileMaxSizeInMB = 1000});
}

abstract class ILogger {
  /// Metodo que inicializa el logger
  ///
  /// Debe ser llamado antes de utilizar cualquier metodo de logeo
  Future<void> init({required LoggerOptions options});
  void info(String message);
  void warn(String message);
  void debug(String message);
  void error(Exception ex);
  Future<void> captureException(error, stackTrace);
}
