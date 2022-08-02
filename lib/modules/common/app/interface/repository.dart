abstract class IRepository {
  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
