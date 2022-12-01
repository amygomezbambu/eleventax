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

  Notificacion copyWith({
    UID? uid,
    TipoNotificacion? tipo,
    String? mensaje,
    String? cuerpo,
    int? timestamp,
  }) {
    var copia = Notificacion.crear(
      tipo: tipo ?? _tipo,
      mensaje: mensaje ?? _mensaje,
    );

    copia._timestamp = timestamp ?? _timestamp;
    copia.uid_ = uid ?? uid_;

    return copia;
  }

  String cuerpoToJson() {
    return '';
  }

  void cargarCuerpoFromJson(String cuerpo) {}
}
