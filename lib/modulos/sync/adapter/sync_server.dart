import 'dart:convert';

import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/sync/change.dart';
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
        var data = jsonDecode(response.body);

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
    String json = '{ "changes": ${jsonEncode(changes)}}';

    try {
      var response = await _client.post(
        Uri.parse(syncConfig!.addChangesEndpoint),
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
