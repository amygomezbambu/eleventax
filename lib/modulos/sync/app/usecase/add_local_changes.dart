import 'package:eleventa/modulos/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/adapter/sync_server.dart';
import 'package:eleventa/modulos/sync/change.dart';
import 'package:eleventa/modulos/sync/merkle.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:hlc/hlc.dart';

class AddChangesRequest {
  List<Change> changes = [];
}

class AddLocalChanges {
  final _config = SyncConfig.get();
  final changesRepo = SyncRepository();
  final syncServer = SyncServer();
  final crdtAdapter = CRDTAdapter();
  final request = AddChangesRequest();

  var merkle = Merkle();
  var firstChange = true;

  late HLC hlc;
  late Change currentChange;

  Future<void> exec() async {
    var serializedMerkle = await changesRepo.getMerkle();

    if (serializedMerkle.isEmpty) {
      merkle = Merkle();
    } else {
      merkle.deserialize(serializedMerkle);
    }

    for (var change in request.changes) {
      currentChange = change;

      //todo: modificar algoritmo para que primero persista todo,
      //luego aplique todo y luego envie todo, si falla la aplicacion
      //se reintenta, si falla el envio se reintenta, el envio no es determinante
      //pero la aplicacion si, si no se puede aplicar truena todo.
      await getHLC();
      merkle.addTimeStamp(change.timestamp);
      await persistChanges();
      await applyChanges();
    }

    await persistMerkle();
  }

  Future<void> getHLC() async {
    if (firstChange) {
      var packedHLC = await changesRepo.getCurrentHLC();

      if (packedHLC.isEmpty) {
        hlc = HLC.now(_config.deviceId);
      } else {
        _determineHLC(packedHLC);
      }

      firstChange = false;
    } else {
      hlc = hlc.increment();
    }

    currentChange.hlc = hlc.pack();
  }

  void _determineHLC(String packedHLC) async {
    HLC newHLC = HLC.now(_config.deviceId);
    HLC currentHLC = HLC.unpack(packedHLC);

    if (currentHLC.compareTo(newHLC) < 0) {
      //newHLC es mayor que currentHLC
      hlc = newHLC;
    } else {
      hlc = currentHLC;
      hlc.increment();
    }
  }

  Future<void> persistChanges() async {
    await changesRepo.add(currentChange);
    await changesRepo.saveCurrentHLC(currentChange.hlc);
  }

  Future<void> persistMerkle() async {
    await changesRepo.saveMerkle(merkle.serialize());
  }

  Future<void> applyChanges() async {
    await crdtAdapter.applyPendingChanges();
  }
}
