import 'package:eleventa/modulos/common/utils/uid.dart';
// ignore: unused_import
import 'package:eleventa/modulos/common/domain/entidad.dart';

abstract class IRepositorio<Entidad> {
  Future<void> agregar(Entidad entity);
  Future<List<Entidad>> obtenerTodos();
  Future<void> actualizar(Entidad entity);
  Future<void> borrar(UID id);

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
