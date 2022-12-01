import 'dart:async';

import 'package:eleventa/modulos/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modulos/sync/entity/change.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:eleventa/modulos/sync/entity/merkle.dart';

class ObtainRemoteChangesRequest {
  var interval = 30000;
  var singleRequest = false;
  var groupId = '';
}

class ObtainRemoteChanges {
  final IServidorSync _servidorSync;
  final IRepositorioSync _repoSync;

  final req = ObtainRemoteChangesRequest();

  Timer? _timer;

  final _crdt = CRDTAdapter();

  ObtainRemoteChanges({
    required IRepositorioSync repoSync,
    required IServidorSync servidorSync,
  })  : _repoSync = repoSync,
        _servidorSync = servidorSync;

  Future<void> exec() async {
    if (req.singleRequest) {
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
      Duration(milliseconds: req.interval),
      (timer) async {
        var changes = await _requestChangesFromServer();
        await _persistChanges(changes);
        await _crdt.applyPendingChanges();
      },
    );
  }

  Future<void> _persistChanges(List<Change> changes) async {
    for (var change in changes) {
      var dbChange = await _repoSync.obtenerCambioPorHLC(change.hlc);

      if (dbChange == null) {
        await _repoSync.agregarCambio(change);
      }
    }
  }

  Future<List<Change>> _requestChangesFromServer() async {
    var serializedMerkle = await _repoSync.obtenerMerkle();
    var merkle = Merkle();
    var hash = '';

    if (serializedMerkle.isNotEmpty) {
      merkle.deserialize(serializedMerkle);
      hash = merkle.tree!.hash.toString();
    }

    var changes = await _servidorSync.obtenerCambios(
      req.groupId,
      serializedMerkle,
      hash,
    );

    return changes;
  }
}
