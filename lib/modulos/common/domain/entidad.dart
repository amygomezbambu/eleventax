import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:meta/meta.dart';

///Clase base de las entidades
///
///Todas las entidades deben extender esta clase
class Entidad {
  @protected
  UID uid_;

  @protected
  bool eliminado_;

  UID get uid => uid_;
  bool get eliminado => eliminado_;

  Entidad.crear()
      : uid_ = UID(),
        eliminado_ = false;

  Entidad.cargar(UID uid, {bool eliminado = false})
      : uid_ = uid,
        eliminado_ = eliminado;

  @protected
  void lanzarExcepcion({required String mensaje}) {
    throw DomainEx(mensaje);
  }

  @override
  bool operator ==(Object other) {
    return (other as Entidad).uid == uid;
  }

  @override
  int get hashCode => uid.hashCode ^ uid.hashCode;
}
