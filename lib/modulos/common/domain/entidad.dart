import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:meta/meta.dart';

///Clase base de las entidades
///
///Todas las entidades deben extender esta clase
class Entidad {
  @protected
  UID internalUID;

  UID get uid => internalUID;

  Entidad.crear() : internalUID = UID();

  Entidad.cargar(UID uid) : internalUID = uid;
}
