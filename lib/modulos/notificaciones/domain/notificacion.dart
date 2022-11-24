import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/notificaciones/usecases/crear_notificacion.dart';

class Notificacion extends Entidad {
  final TipoNotificacion _tipo;
  final String _mensaje;
  late int _timestamp;

  TipoNotificacion get tipo => _tipo;
  String get mensaje => _mensaje;
  int get timestamp => _timestamp;

  Notificacion.crear({
    required TipoNotificacion tipo,
    required String mensaje,
  })  : _tipo = tipo,
        _mensaje = mensaje,
        super.crear() {
    _timestamp = DateTime.now().millisecondsSinceEpoch;
  }

  Notificacion.cargar({
    required UID uid,
    required TipoNotificacion tipo,
    required String mensaje,
  })  : _tipo = tipo,
        _mensaje = mensaje,
        super.cargar(uid);
}
