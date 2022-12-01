import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/notificaciones/domain/notificacion.dart';
import 'package:eleventa/modulos/notificaciones/interfaces/repositorio_notificaciones.dart';

enum TipoNotificacion { info, alerta, conflictoSync, error }

class CrearNotificacionRequest {
  late TipoNotificacion tipo;
  late Notificacion notificacion;
}

class CrearNotificacion extends Usecase<void> {
  final req = CrearNotificacionRequest();
  final IRepositorioNotificaciones _notificaciones;

  CrearNotificacion(IRepositorioNotificaciones notificaciones)
      : _notificaciones = notificaciones,
        super(notificaciones) {
    operation = _operation;
  }

  Future<void> _operation() async {
    await _notificaciones.agregar(req.notificacion);
  }
}
