import 'package:eleventa/modulos/common/utils/uid.dart';

abstract class IRepositorio<Entity> {
  Future<void> agregar(Entity entity);
  Future<Entity?> obtener(UID uid);
  Future<List<Entity>> obtenerTodos();
  Future<void> actualizar(Entity entity);
  Future<void> borrar(UID id);

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
