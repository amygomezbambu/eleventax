abstract class IAdaptadorDeBaseDeDatos {
  /// Activa el logeo en consola de los queries y commands de sqlite
  set verbose(bool value);

  /// Create a connection to the dabatase
  Future<void> conectar({bool verbose = false});
  Future<void> command({
    required String sql,
    List<Object?>? params,
  });
  Future<List<Map<String, Object?>>> query({
    required String sql,
    List<Object?>? params,
  });

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
