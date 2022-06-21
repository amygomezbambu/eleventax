class EleventaError implements Exception {
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  String stackTrace;
  bool compactLogging = false;

  EleventaError(this.message, this.stackTrace);
}