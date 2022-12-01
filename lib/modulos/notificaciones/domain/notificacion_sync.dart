import 'dart:convert';

import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/notificaciones/domain/notificacion.dart';

class NotificacionSync extends Notificacion {
  UID uidDuplicados;

  NotificacionSync.crear({
    required this.uidDuplicados,
    required super.tipo,
    required super.mensaje,
  }) : super.crear();

  @override
  String cuerpoToJson() {
    return jsonEncode({'uidDuplicados': uidDuplicados.toString()});
  }

  @override
  void cargarCuerpoFromJson(String cuerpo) {
    var data = jsonDecode(cuerpo);

    uidDuplicados = UID.fromString(data['uidDuplicados']);
  }
}
