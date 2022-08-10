class EleventaException implements Exception {
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  StackTrace? stackTrace;
  Exception? innerException;
  bool compactLogging = false;

  EleventaException(
      {required this.message, this.innerException, this.stackTrace});
}

class DomainException extends EleventaException {
  DomainException(String message) : super(message: message) {
    compactLogging = true;
  }
}

class AppException extends EleventaException {
  AppException(String message) : super(message: message);
}

class InfrastructureException extends EleventaException {
  InfrastructureException(String message, Exception ex, StackTrace? stackTrace)
      : super(message: message, innerException: ex, stackTrace: stackTrace);
}
