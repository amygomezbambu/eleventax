import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/unique_duplicate.dart';

/// Metodos de resolución posibles
///
/// [firstWin] indica que eran la misma entidad y se desean conservar los datos del primero
/// en suceder
///
/// [lastWin] indica que eran la misma entidad y se desean conservar los datos del utimo
/// en suceder
///
/// [rename] indica que las entidades en realidad eran distintas y la solución en simplemente
/// renombrar el unique de una de ellas
///
/// [merge] indica que eran la misma entidad y se desea mergear sus campos. NO se recomienda
/// ya que generalmente si existe un conflicto y se usa esta opcion ganaran todos los campos
/// del ultimo en suceder, es decir en la practica es igual que usar [lastWin]
enum SyncConflictResolution {
  firstWin,
  lastWin,
  merge,
  rename,
}

class ResolveConflictRequest {
  String uid;
  SyncConflictResolution resolution;
  String? renameValue;

  ResolveConflictRequest({
    required this.uid,
    required this.resolution,
    this.renameValue,
  });
}

class ResolveConflict {
  final _repo = SyncRepository();
  final _sync = Sync.getInstance();

  late final ResolveConflictRequest _req;

  Future<void> exec(ResolveConflictRequest request) async {
    _req = request;

    var duplicado = await _repo.obtenerDuplicado(_req.uid);

    switch (_req.resolution) {
      case SyncConflictResolution.firstWin:
        await _firstWin(duplicado);
        break;
      case SyncConflictResolution.lastWin:
        await _lastWin(duplicado);
        break;
      case SyncConflictResolution.merge:
        await _merge(duplicado);
        break;
      case SyncConflictResolution.rename:
        await _rename(duplicado);
        break;
    }

    await _deleteDuplicate(duplicado);
  }

  Future<void> _firstWin(UniqueDuplicate duplicado) async {
    //si es firstWin se usan los valores del primero y el segundo se descarta(default),
    //es decir se marca como borrado
    var sql = 'update ${duplicado.dataset} set borrado = true where uid = ?;';

    await _repo.ejecutarComandoRaw(sql, [duplicado.happenLastUID]);

    await _sync.synchronize(
      dataset: duplicado.dataset,
      rowID: duplicado.happenLastUID,
      fields: {
        'borrado': true,
      },
    );
  }

  Future<void> _lastWin(UniqueDuplicate duplicado) async {
    //si es lastWin se usan los valores del ultimo, se marca como activo y
    //el primero se marca como borrado
    var sql =
        'update ${duplicado.dataset} set borrado = true, bloqueado = true where uid = ?;';

    await _repo.ejecutarComandoRaw(sql, [duplicado.happenFirstUID]);

    await _sync.synchronize(
      dataset: duplicado.dataset,
      rowID: duplicado.happenFirstUID,
      fields: {
        'borrado': true,
        'bloqueado': true,
      },
    );

    sql = 'update ${duplicado.dataset} set bloqueado = false where uid = ?;';

    await _repo.ejecutarComandoRaw(sql, [duplicado.happenLastUID]);

    await _sync.synchronize(
      dataset: duplicado.dataset,
      rowID: duplicado.happenLastUID,
      fields: {
        'bloqueado': false,
      },
    );
  }

  Future<void> _merge(UniqueDuplicate duplicado) async {}

  Future<void> _rename(UniqueDuplicate duplicado) async {
    //si es rename eran distintas entidades, se modifica el unique de la entidad bloqueada,
    //y se marca como activa

    var sql = 'update ${duplicado.dataset} set ${duplicado.column} = ?, '
        'bloqueado = false where uid = ?;';

    await _repo.ejecutarComandoRaw(sql, [
      _req.renameValue,
      duplicado.happenLastUID,
    ]);

    await _sync.synchronize(
      dataset: duplicado.dataset,
      rowID: duplicado.happenLastUID,
      fields: {
        duplicado.column: _req.renameValue!,
        'bloqueado': false,
      },
    );
  }

  Future<void> _deleteDuplicate(UniqueDuplicate duplicado) async {
    await _repo.ejecutarComandoRaw(
      'delete from sync_duplicados where uid = ?',
      [duplicado.uid],
    );
  }
}
