import 'package:eleventa/modules/common/utils/uid.dart';

abstract class IRepository<Entity> {
  Future<void> add(Entity entity);
  Future<Entity?> getSingle(UID uid);
  Future<List<Entity>> getAll();
  Future<void> update(Entity entity);
  Future<void> delete(UID id);

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
