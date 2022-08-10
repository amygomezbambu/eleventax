import 'dart:convert';

import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/sync/change.dart';
import 'package:eleventa/modules/sync/sync_config.dart';
import 'package:http/http.dart' as http;

class SyncServer {
  final _config = SyncConfig.get();

  SyncServer();

  /// Obtiene los cambios de otros nodos que este nodo no tiene aun
  Future<List<Change>> obtain(
      String groupId, String merkle, String hash) async {
    List<Change> changes = [];
    String json =
        '{ "groupId": "$groupId", "merkle": "$merkle", "hash": "$hash"}';

    var response = await http.post(
      Uri.parse(_config.getChangesEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json,
    );

    if (response.statusCode != 200) {
      throw InfrastructureException(
        'Error en el envio de cambios a nube',
        Exception(response.body),
        null,
      );
    } else {
      var data = jsonDecode(response.body);

      if (data['changesCount'] != 0) {
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

  /// Envia los cambios al servidor de sincronización
  Future<void> send(List<Change> changes) async {
    String json = '{ "changes": ${jsonEncode(changes)}}';

    var response = await http.post(
      Uri.parse(_config.addChangesEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json,
    );

    if (response.statusCode != 200) {
      throw InfrastructureException(
        'Error en el envio de cambios a nube',
        Exception(response.body),
        null,
      );
    }
  }
}
