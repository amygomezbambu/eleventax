import 'dart:async';

import 'package:eleventa/modulos/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/adapter/sync_server.dart';
import 'package:eleventa/modulos/sync/change.dart';
import 'package:eleventa/modulos/sync/merkle.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';

class ObtainRemoteChangesRequest {
  var interval = 30000;
  var singleRequest = false;
}

class ObtainRemoteChanges {
  final request = ObtainRemoteChangesRequest();

  Timer? _timer;
  final _config = SyncConfig.get();

  final _server = SyncServer();
  final _repo = SyncRepository();
  final _crdt = CRDTAdapter();

  /* #region Singleton */
  static final instance = ObtainRemoteChanges._internal();

  ObtainRemoteChanges._internal();
  /* #endregion */

  Future<void> exec() async {
    if (request.singleRequest) {
      if (_timer != null && _timer!.isActive) {
        stop();
      }

      var changes = await _requestChangesFromServer();
      await _persistChanges(changes);
      await _crdt.applyPendingChanges();
    }

    await initListening();
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> initListening() async {
    _timer = Timer.periodic(
      Duration(milliseconds: request.interval),
      (timer) async {
        var changes = await _requestChangesFromServer();
        await _persistChanges(changes);
        await _crdt.applyPendingChanges();
      },
    );
  }

  Future<void> _persistChanges(List<Change> changes) async {
    for (var change in changes) {
      var dbChange = await _repo.getByHLC(change.hlc);

      if (dbChange == null) {
        await _repo.add(change);
      }
    }
  }

  Future<List<Change>> _requestChangesFromServer() async {
    var serializedMerkle = await _repo.getMerkle();
    var merkle = Merkle();
    var hash = '';

    if (serializedMerkle.isNotEmpty) {
      merkle.deserialize(serializedMerkle);
      hash = merkle.tree!.hash.toString();
    }

    var changes = await _server.obtain(_config.groupId, serializedMerkle, hash);

    return changes;
  }
}
