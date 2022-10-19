import 'package:eleventa/modulos/common/domain/respuesta_de_validacion.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
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

  @protected
  void lanzarExcepcion({required String mensaje}) {
    throw DomainEx(mensaje);
  }

  @protected
  T validarYAsignar<T>(T valor, RespuestaValidacion Function(T) validador) {
    var respuesta = validador(valor);

    if (!respuesta.esValido) {
      lanzarExcepcion(mensaje: respuesta.mensaje);
    }

    return valor;
  }
}
