import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/notificaciones/domain/notificacion.dart';

enum TipoNotificacion { info, alerta, conflictoSync, error }

class CrearNotificacionRequest {
  var tipo = TipoNotificacion.info;
  var mensaje = '';
}

class CrearNotificacion extends Usecase<void> {
  var req = CrearNotificacionRequest();

  CrearNotificacion() : super() {
    operation = _operation;
  }

  Future<void> _operation() async {
    Notificacion.crear(tipo: req.tipo, mensaje: req.mensaje);
  }
}
