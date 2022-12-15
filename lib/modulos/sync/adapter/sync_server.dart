import 'dart:convert';

import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/sync/entity/change.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:http/http.dart' show Client;

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
      var response = await _client.post(
        Uri.parse(syncConfig!.getChangesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json,
      );

      if (response.statusCode != 200) {
        throw InfraEx(
          message: 'Error en el envio de cambios a nube',
          innerException: Exception(response.body),
          stackTrace: StackTrace.current,
          input: json,
        );
      } else {
        changes = jsonPayloadToChanges(response.body);
      }
    } catch (e, stack) {
      if (e is InfraEx) {
        rethrow;
      } else {
        throw SyncEx(e.toString(), stack.toString());
      }
    }

    return changes;
  }

  /// Envia los cambios al servidor de sincronización
  ///
  @override
  Future<void> enviarCambios(List<Change> changes) async {
    try {
      var response = await _client.post(
        Uri.parse(syncConfig!.addChangesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: changesToJsonPayload(changes),
      );

      //TODO: sync no debe depender de los errores de eleventa o decidir si vamos a
      //acoplar
      if (response.statusCode != 200) {
        throw InfraEx(
          message: 'Error en el envio de cambios a nube',
          innerException: Exception(response.body),
          stackTrace: StackTrace.current,
          input: changesToJsonPayload(changes),
        );
      }
    } catch (e, stack) {
      if (e is InfraEx) {
        rethrow;
      } else {
        throw SyncEx(e.toString(), stack.toString());
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
        throw InfraEx(
          message: 'Error en el envio de cambios a nube',
          innerException: Exception(response.body),
          stackTrace: StackTrace.current,
          input: payload,
        );
      }
    } catch (e, stack) {
      if (e is InfraEx) {
        rethrow;
      } else {
        throw SyncEx(e.toString(), stack.toString());
      }
    }
  }
}
