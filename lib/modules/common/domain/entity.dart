import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:meta/meta.dart';

///Clase base de las entidades
///
///Todas las entidades deben extender esta clase
class Entity {
  @protected
  UID internalUID;

  UID get uid => internalUID;

  Entity.create() : internalUID = UID();

  Entity.load(UID uid) : internalUID = uid;
}
