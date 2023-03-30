import 'dart:convert';

import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:hlc/hlc.dart';

class ObtenerEventosResponse implements IObtenerEventosResponse {
  @override
  late final List<EventoSync> eventos;
  @override
  late final int epochDeSincronizacion;

  ObtenerEventosResponse({required String payload}) {
    eventos = _parsearPayload(payload);
  }

  ///
  /// {
  ///   eventos: [
  ///      {}
  ///   ],
  ///   hayEventosPendientes: true | false
  /// }
  ///
  /// //TODO: Manejar eventos pendientes
  List<EventoSync> _parsearPayload(String payload) {
    List<EventoSync> eventos = [];

    var data = jsonDecode(payload);

    epochDeSincronizacion = data['fecha_sincronizacion'];

    for (var eventoJson in data['eventos']) {
      List<CampoEventoSync> campos = [];
      EventoSync evento;

      for (var campo in eventoJson['campos']) {
        campos.add(
          CampoEventoSync.cargar(
            nombre: campo['nombre'],
            valor: campo['valor'],
            tipo: campo['tipo'],
          ),
        );
      }

      evento = EventoSync(
        dataset: eventoJson['dataset'] as String,
        dispositivoID: eventoJson['dispositivo_id'] as String,
        usuarioUID: eventoJson['usuario_uid'] as String,
        rowId: eventoJson['rowId'] as String,
        version: eventoJson['version'] as int,
        tipo: TipoEventoSync.values[(eventoJson['tipo_evento'] as int)],
        campos: campos,
      );

      evento.hlc = HLC.unpack(eventoJson['hlc'] as String);

      eventos.add(evento);
    }

    return eventos;
  }
}
