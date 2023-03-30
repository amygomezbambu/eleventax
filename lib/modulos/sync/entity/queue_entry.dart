class QueueEntry {
  final String uid;
  final String body;
  final Map<String, String> headers;

  QueueEntry({
    required this.uid,
    required this.body,
    required this.headers,
  });
}
