class EleventaException implements Exception {
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  String stackTrace;
  bool compactLogging = false;

  EleventaException(this.message, this.stackTrace);
}

class DomainException extends EleventaException {
  DomainException(String message) : super(message, '') {
    compactLogging = true;
  }
}

class AppException extends EleventaException {
  AppException(String message) : super(message, '');
}

class InfrastructureError extends EleventaException {
  InfrastructureError(String message, String stackTrace)
      : super(message, stackTrace);
}
