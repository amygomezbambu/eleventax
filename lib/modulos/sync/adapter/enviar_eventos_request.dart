import 'dart:convert';

import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';

class EnviarEventosRequest {
  late final Map<String, String> headers;
  late final String body;
  late final Uri uri;

  EnviarEventosRequest({required List<EventoSync> eventos}) {
    uri = Uri.parse(syncConfig!.addChangesEndpoint);
    headers = _construirHeaders();
    body = _construirBody(eventos);
  }

  Map<String, String> _construirHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'sucursal_Id': syncConfig!.groupId,
      'dispositivo_Id': syncConfig!.deviceId,
    };
  }

  String _construirBody(List<EventoSync> eventos) {
    var json = '{ "eventos": [ ';

    for (var evento in eventos) {
      json += '${jsonEncode(evento)},';
    }

    json = json.substring(0, json.length - 1);
    json = '$json]}';

    return json;
  }
}
