import 'dart:convert';

import 'package:eleventa/modulos/sync/entity/change.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:http/http.dart' show Client, Response;

class SyncServer implements IServidorSync {
  final Client _client;

  SyncServer({Client? client}) : _client = client ?? Client();

  /// Obtiene los cambios de otros nodos que este nodo no tiene aun
  @override
  Future<List<Change>> obtenerCambios(
    String groupId,
    String merkle,
    String hash,
  ) async {
    List<Change> changes = [];
    String json =
        '{ "groupId": "$groupId", "merkle": "$merkle", "hash": "$hash"}';

    try {
      var response = await _client
          .post(
        Uri.parse(syncConfig!.getChangesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json,
      )
          .timeout(
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
          tipo: TiposSyncEx.errorAlSubirCambios,
          message:
              'Error en el envio de cambios a nube\n ${response.body} \n, Stack: $json${StackTrace.current}',
        );
      } else {
        changes = jsonPayloadToChanges(response.body);
      }
    } catch (e, stack) {
      if (e is SyncEx) {
        rethrow;
      } else {
        throw SyncEx(
            tipo: TiposSyncEx.errorAlSubirCambios,
            message: '$e, Stack: $stack');
      }
    }

    return changes;
  }

  /// Envia los cambios al servidor de sincronización
  ///
  @override
  Future<void> enviarCambios(List<Change> changes) async {
    try {
      var response = await _client
          .post(
        Uri.parse(syncConfig!.addChangesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: changesToJsonPayload(changes),
      )
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
          tipo: TiposSyncEx.errorAlSubirCambios,
          message:
              'Error en el envio de cambios a nube\n ${response.body} \n ${changesToJsonPayload(changes)}, Stack Trace: ${StackTrace.current}',
        );
      }
    } catch (e) {
      if (e is SyncEx) {
        rethrow;
      } else {
        throw SyncEx(
          tipo: TiposSyncEx.errorAlSubirCambios,
          message: e.toString(),
        );
      }
    }
  }

  @override
  String changesToJsonPayload(List<Change> changes) {
    return '{ "changes": ${jsonEncode(changes)}}';
  }

  @override
  List<Change> jsonPayloadToChanges(String payload) {
    List<Change> changes = [];

    var data = jsonDecode(payload);

    if (data['changesCount'] != 0) {
      if (data['changes'] != null) {
        for (var change in data['changes']) {
          changes.add(Change.load(
              column: change['column'],
              value: change['value'],
              dataset: change['dataset'],
              rowId: change['rowId'],
              hlc: change['hlc'],
              version: int.parse(change['version'])));
        }
      }
    }

    return changes;
  }

  @override
  Future<void> enviarPayload(String payload) async {
    try {
      var response = await _client.post(
        Uri.parse(syncConfig!.addChangesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: payload,
      );

      if (response.statusCode != 200) {
        throw SyncEx(
            tipo: TiposSyncEx.errorAlSubirCambios,
            message:
                'Error en el envio de cambios a nube\n ${response.body} \n $json');
      }
    } catch (e) {
      if (e is SyncEx) {
        rethrow;
      } else {
        throw SyncEx(
          tipo: TiposSyncEx.errorAlSubirCambios,
          message: e.toString(),
        );
      }
    }
  }
}
