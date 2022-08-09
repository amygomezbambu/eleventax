class EleventaException implements Exception {
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  StackTrace? stackTrace;
  bool compactLogging = false;

  EleventaException(this.message, this.stackTrace);
}

class DomainException extends EleventaException {
  DomainException(String message) : super(message, null) {
    compactLogging = true;
  }
}

class AppException extends EleventaException {
  AppException(String message) : super(message, null);
}

class InfrastructureError extends EleventaException {
  InfrastructureError(String message, StackTrace stackTrace)
      : super(message, stackTrace);
}
