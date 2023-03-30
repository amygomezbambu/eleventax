import 'dart:convert';

import 'package:eleventa/modulos/sync/adapter/enviar_eventos_request.dart';
import 'package:eleventa/modulos/sync/adapter/obtener_eventos_response.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:http/http.dart' show Client, Response;

class SyncServer implements IServidorSync {
  final Client _client;

  SyncServer({Client? client}) : _client = client ?? Client();

  /// Obtiene los cambios de otros nodos que este nodo no tiene aun
  @override
  Future<ObtenerEventosResponse> obtenerEventos(
    int ultimaSincronizacion,
  ) async {
    ObtenerEventosResponse respuestaParseada;

    try {
      var response = await _client.get(
        Uri.parse(syncConfig!.getChangesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'sucursal_Id': syncConfig!.groupId,
          'dispositivo_Id': syncConfig!.deviceId,
          'ultima_sincronizacion': ultimaSincronizacion.toString(),
        },
      ).timeout(
        syncConfig!.timeout,
        onTimeout: () async {
          return Response(
            'Timeout al intentar obtener cambios del server de sincronización.',
            408,
          );
        },
      );

      if (response.statusCode != 200) {
        throw SyncEx(
          tipo: TiposSyncEx.errorAlSubirEventos,
          message: 'Error en el envio de cambios a nube\n '
              '${response.body} \n, Stack: ${StackTrace.current}',
        );
      } else {
        respuestaParseada = ObtenerEventosResponse(payload: response.body);
      }
    } catch (e, stack) {
      if (e is SyncEx) {
        rethrow;
      } else {
        throw SyncEx(
            tipo: TiposSyncEx.errorAlSubirEventos,
            message: '$e, Stack: $stack');
      }
    }

    return respuestaParseada;
  }

  /// Envia los cambios al servidor de sincronización
  ///
  @override
  Future<void> enviarEvento(EventoSync evento) async {
    try {
      var request = EnviarEventosRequest(eventos: [evento]);

      var response = await _client
          .post(request.uri, headers: request.headers, body: request.body)
          .timeout(
        syncConfig!.timeout,
        onTimeout: () async {
          return Response(
            'Timeout al intentar enviar los cambios al server de sincronización.',
            408,
          );
        },
      );

      if (response.statusCode != 200) {
        throw SyncEx(
          tipo: TiposSyncEx.errorAlSubirEventos,
          message: 'Error en el envio de eventos a nube \n'
              ' ${response.body} \n'
              ' Stack Trace: ${StackTrace.current}',
        );
      }
    } catch (e) {
      if (e is SyncEx) {
        rethrow;
      } else {
        //TODO: este else no tiene sentido
        throw SyncEx(
          tipo: TiposSyncEx.errorAlSubirEventos,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Future<void> enviarRaw({
    required String body,
    required Map<String, String> headers,
  }) async {
    //TODO: para generar los headers tenemos que guardar tambien los headers o el evento
    //completo en el queue
    try {
      var response = await _client.post(
        Uri.parse(syncConfig!.addChangesEndpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw SyncEx(
            tipo: TiposSyncEx.errorAlSubirEventos,
            message:
                'Error en el envio de cambios a nube\n ${response.body} \n $json');
      }
    } catch (e) {
      if (e is SyncEx) {
        rethrow;
      } else {
        throw SyncEx(
          tipo: TiposSyncEx.errorAlSubirEventos,
          message: e.toString(),
        );
      }
    }
  }
}
