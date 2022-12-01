import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/notificaciones/usecases/crear_notificacion.dart';

class ModuloNotificaciones {
  static CrearNotificacion crearNotificacion() {
    return CrearNotificacion(
      Dependencias.notificaciones.repositorioNotificaciones(),
    );
  }
}
