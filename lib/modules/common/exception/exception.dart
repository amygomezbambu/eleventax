class EleventaException implements Exception {
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  StackTrace? stackTrace;
  Object? innerException;

  /// representa los datos que fueron proporcionados al metodo que causo el error
  String? input;

  EleventaException({
    required this.message,
    this.innerException,
    this.stackTrace,
    this.input,
  }) {
    stackTrace ??= StackTrace.current;
  }

  @override
  String toString() {
    return '${runtimeType.toString()}: $message\n'
        '[Tech Info]: ${innerException?.toString()}';
  }
}

class DomainException extends EleventaException {
  DomainException(String message) : super(message: message);
}

class AppException extends EleventaException {
  AppException({required String message, String? input})
      : super(message: message, input: input);
}

class InfrastructureException extends EleventaException {
  InfrastructureException({
    required String message,
    required Object innerException,
    StackTrace? stackTrace,
    String? input,
  }) : super(
          message: message,
          innerException: innerException,
          stackTrace: stackTrace,
          input: input,
        );
}
