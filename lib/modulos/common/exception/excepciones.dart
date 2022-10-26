class EleventaEx implements Exception {
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  StackTrace? stackTrace;
  Object? innerException;

  /// representa los datos que fueron proporcionados al metodo que causo el error
  String? input;

  EleventaEx({
    required this.message,
    this.innerException,
    this.stackTrace,
    this.input,
  }) {
    stackTrace ??= StackTrace.current;
  }

  @override
  String toString() {
    return '${runtimeType.toString()}: $message\n';
  }
}

class DomainEx extends EleventaEx {
  DomainEx(String message) : super(message: message);
}

class AppEx extends EleventaEx {
  AppEx({required String message, String? input})
      : super(message: message, input: input);
}

class InfraEx extends EleventaEx {
  InfraEx({
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
