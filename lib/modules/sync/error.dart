class SyncError implements Exception {
  String message;
  String stackTrace;

  SyncError(this.message, this.stackTrace);
}
