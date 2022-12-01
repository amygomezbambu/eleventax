import 'package:eleventa/modulos/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modulos/sync/entity/change.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/entity/merkle.dart';
import 'package:hlc/hlc.dart';

class AddChangesRequest {
  List<Change> changes = [];
  var deviceId = '';
}

class AddLocalChanges {
  final req = AddChangesRequest();
  final IRepositorioSync _repoSync;
  final crdtAdapter = CRDTAdapter();

  var merkle = Merkle();
  var firstChange = true;

  late HLC hlc;
  late Change currentChange;

  AddLocalChanges({required IRepositorioSync repoSync}) : _repoSync = repoSync;

  Future<void> exec() async {
    var serializedMerkle = await _repoSync.obtenerMerkle();

    if (serializedMerkle.isEmpty) {
      merkle = Merkle();
    } else {
      merkle.deserialize(serializedMerkle);
    }

    for (var change in req.changes) {
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
      var packedHLC = await _repoSync.obtenerHLCActual();

      if (packedHLC.isEmpty) {
        hlc = HLC.now(req.deviceId);
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
    HLC newHLC = HLC.now(req.deviceId);
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
    await _repoSync.agregarCambio(currentChange);
    await _repoSync.actualizarHLCActual(currentChange.hlc);
  }

  Future<void> persistMerkle() async {
    await _repoSync.actualizarMerkle(merkle.serialize());
  }

  Future<void> applyChanges() async {
    await crdtAdapter.applyPendingChanges();
  }
}
