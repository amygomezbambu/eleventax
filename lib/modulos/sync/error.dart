class SyncError implements Exception {
  String message;
  String stackTrace;

  SyncError(this.message, this.stackTrace);

  @override
  String toString() {
    return '${runtimeType.toString()}: $message \n stack: $stackTrace';
  }
}
