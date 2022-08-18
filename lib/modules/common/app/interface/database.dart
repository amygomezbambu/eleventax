abstract class IDatabaseAdapter {
  /// Create a connection to the dabatase
  Future<void> connect();
  Future<void> command({required String sql, List<Object?>? params});
  Future<List<Map<String, Object?>>> query(
      {required String sql, List<Object?>? params});

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
