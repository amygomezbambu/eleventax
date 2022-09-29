import 'package:eleventa/modulos/common/exception/excepciones.dart';

///Buenas practicas:
///1.Generar el log en JSON u otro formato que se pueda manejar mas facil que el texto plano
///2.Agregar contexto, dispositivo, usuario, request, caso de uso, si es una falla de infraestructura
///por ejemplo la db, agregar tamaño de la db y otras metricas que ayuden a saber si hay algo
///riesgoso (por ejemplo si es una db gigante)
///3.Write meaningfull log messages(and meaningfull errors)
class EntradaDeLog {
  var timestamp = 0;
  var userId = '';
  var deviceId = '';
  String? input = '';
  var message = '';
  Object? exception;
  StackTrace? stackTrace;
}

enum NivelDeLog { info, debug, error, warning, all }

class LoggerConfig {
  final List<NivelDeLog> _nivelesRemotos;
  final List<NivelDeLog> _nivelesDeArchivo;
  final List<NivelDeLog> _nivelesDeConsola;
  final int _tamanioMaximoEnMB;

  List<NivelDeLog> get nivelesRemotos => _nivelesRemotos;
  List<NivelDeLog> get nivelesDeArchivo => _nivelesDeArchivo;
  List<NivelDeLog> get nivelesDeConsola => _nivelesDeConsola;
  int get tamanioMaximoEnMB => _tamanioMaximoEnMB;

  LoggerConfig({
    required List<NivelDeLog> nivelesRemotos,
    required List<NivelDeLog> nivelesDeArchivo,
    required List<NivelDeLog> nivelesDeConsola,
    int tamanioMaximoEnMB = 1000,
  })  : _nivelesDeArchivo = nivelesDeArchivo,
        _nivelesDeConsola = nivelesDeConsola,
        _nivelesRemotos = nivelesRemotos,
        _tamanioMaximoEnMB = tamanioMaximoEnMB;
}

abstract class ILogger {
  /// Metodo que inicializa el logger
  ///
  /// Debe ser llamado antes de utilizar cualquier metodo de logeo
  Future<void> iniciar({required LoggerConfig config});
  void info(String message);

  /// Logea un warning
  ///
  /// recibe [EleventaEx] debido a que un warn siempre se lanza manualmente
  void warn(EleventaEx ex);
  void debug({required String message, Exception? ex, StackTrace? stackTrace});
  void error({required Object ex, StackTrace? stackTrace});
}
