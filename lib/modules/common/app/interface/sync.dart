abstract class ISync {
  Future<void> syncChanges({
    required String dataset,
    required String rowID,
    required Map<String, Object?> fields,
  });
  Future<void> initListening();
  void stopListening();
}
