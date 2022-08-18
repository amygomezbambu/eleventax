abstract class ISync {
  Future<void> syncChanges({
    required String dataset,
    required String rowID,
    required List<String> columns,
    required List<Object?> values,
  });
  Future<void> initListening();
  void stopListening();
}
