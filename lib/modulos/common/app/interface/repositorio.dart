import 'package:eleventa/modulos/common/utils/uid.dart';
// ignore: unused_import
import 'package:eleventa/modulos/common/domain/entidad.dart';

abstract class IRepositorio<Entidad> {
  Future<void> agregar(Entidad entity);
  Future<void> modificar(Entidad entity);
  Future<void> eliminar(UID id);

  Future<void> transaction();
  Future<void> commit();
  Future<void> rollback();
}
