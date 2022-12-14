typedef QueryResult = List<Map<String, Object?>>;
typedef QueryParams = List<Object?>?;

abstract class IAdaptadorDeBaseDeDatos {
  /// Activa el logeo en consola de los queries y commands de sqlite
  set verbose(bool value);

  /// Create a connection to the dabatase
  Future<void> conectar({bool verbose = false});
  Future<void> command({
    required String sql,
    List<Object?>? params,
  });
  Future<QueryResult> query({
    required String sql,
    QueryParams params,
  });

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
