import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:meta/meta.dart';

///Clase base de las entidades
///
///Todas las entidades deben extender esta clase
class Entidad {
  @protected
  UID uidInterno;
  UID get uid => uidInterno;

  Entidad.crear() : uidInterno = UID();

  Entidad.cargar(UID uid) : uidInterno = uid;

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
