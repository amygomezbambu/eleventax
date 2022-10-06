class SyncEx implements Exception {
  String message;
  String stackTrace;

  SyncEx(this.message, this.stackTrace);

  @override
  String toString() {
    return '${runtimeType.toString()}: $message \n stack: $stackTrace';
  }
}
