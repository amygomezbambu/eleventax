import 'package:eleventa/modules/sync/adapter/sync_repository.dart';
import 'package:eleventa/modules/sync/change.dart';
import 'package:hlc/hlc.dart';

/// Controla la aplicacion de los cambios a la base de datos
///
/// Decide si un cambio debe ser aplicado o descartado
class CRDTAdapter {
  final repo = SyncRepository();
  final pendingChanges = <Change>[];

  CRDTAdapter();

  Future<void> applyPendingChanges() async {
    var pendingChanges = await repo.getUnappliedChanges();

    for (var change in pendingChanges) {
      var newerChangesCount = await repo.getNewerChangesCount(change);

      if (newerChangesCount == 0) {
        await _applyChange(change);
        await _updateHLC(change.hlc);
      } else {
        await _discardChange(change);
      }
    }
  }

  Future<void> _applyChange(Change change) async {
    var command = '';
    var rowExist = await repo.rowExist(change.dataset, change.rowId);

    if (!rowExist) {
      command =
          'insert into ${change.dataset}(uid,${change.column}) values(?,?);';

      await repo.executeCommand(command, [change.rowId, change.value]);
    } else {
      command =
          'update ${change.dataset} set ${change.column} = ? where uid = ?;';

      await repo.executeCommand(command, [change.value, change.rowId]);
    }

    //marcar el cambio como aplicado
    await repo.updateAppliedChange(change);
  }

  Future<void> _discardChange(Change change) async {
    await repo.updateAppliedChange(change);
  }

  Future<void> _updateHLC(String changeHLC) async {
    HLC localHLC;
    HLC remoteHLC = HLC.unpack(changeHLC);

    var currentHLC = await repo.getCurrentHLC();

    if (currentHLC.isEmpty) {
      await repo.saveCurrentHLC(remoteHLC.pack());
    } else {
      localHLC = HLC.unpack(currentHLC);

      if (localHLC.compareTo(remoteHLC) < 0) {
        await repo.saveCurrentHLC(remoteHLC.pack());
      }
    }
  }
}
