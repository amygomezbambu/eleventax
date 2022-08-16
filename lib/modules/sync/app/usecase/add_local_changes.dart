import 'package:eleventa/modules/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modules/sync/adapter/sync_repository.dart';
import 'package:eleventa/modules/sync/adapter/sync_server.dart';
import 'package:eleventa/modules/sync/change.dart';
import 'package:eleventa/modules/sync/merkle.dart';
import 'package:eleventa/modules/sync/sync_config.dart';
import 'package:hlc/hlc.dart';

class AddChangesRequest {
  List<Change> changes = [];
  var waitForSync = false;
}

class AddLocalChanges {
  final _config = SyncConfig.get();

  var changesRepo = SyncRepository();
  var syncServer = SyncServer();
  var crdtAdapter = CRDTAdapter();

  var request = AddChangesRequest();

  late HLC hlc;
  late Change currentChange;
  Merkle merkle = Merkle();

  bool firstChange = true;

  Future<void> exec() async {
    var serializedMerkle = await changesRepo.getMerkle();

    if (serializedMerkle == '') {
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

    if (request.waitForSync) {
      await sendChanges();
    } else {
      sendChanges();
    }
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

  Future<void> sendChanges() async {
    await syncServer.send(request.changes);
  }
}
