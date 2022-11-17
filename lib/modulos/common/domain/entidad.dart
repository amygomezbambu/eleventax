import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:meta/meta.dart';

///Clase base de las entidades
///
///Todas las entidades deben extender esta clase
class Entidad {
  @protected
  final UID _uid;

  UID get uid => _uid;

  Entidad.crear() : _uid = UID();

  Entidad.cargar(UID uid) : _uid = uid;

  @protected
  void lanzarExcepcion({required String mensaje}) {
    throw DomainEx(mensaje);
  }

  @override
  bool operator ==(Object other) {
    //if (identical(this, other)) return true;

    return (other as Entidad).uid == _uid;
  }

  @override
  int get hashCode => _uid.hashCode ^ uid.hashCode;
}
