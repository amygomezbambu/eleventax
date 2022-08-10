import 'package:eleventa/modules/sync/adapter/sync_repository.dart';
import 'package:eleventa/modules/sync/app/usecase/add_local_changes.dart';
import 'package:eleventa/modules/sync/app/usecase/obtain_remote_changes.dart';
import 'package:eleventa/modules/sync/change.dart';
import 'package:eleventa/modules/sync/sync_config.dart';
import 'package:hlc/hlc.dart';

/// Clase principal de Sincronización
///
/// A travez de esta clase se accede a todos los servicios de sincronización
class Sync {
  late SyncConfig _config;

  final _repo = SyncRepository();
  final _obtainRemoteChanges = ObtainRemoteChanges();
  final _addLocalChanges = AddLocalChanges();

  // #region singleton
  static final Sync _instance = Sync._internal();

  factory Sync({required SyncConfig syncConfig}) {
    var instance = _instance;

    instance._config = syncConfig;

    return instance;
  }

  Sync._internal();
  // #endregion

  /// Sincroniza los cambios.
  ///
  /// Para cada columna en [columns] y su respectivo valor en [values]
  /// aplica los cambios a la base de datos local en la tabla [dataset] y
  /// el row [rowID] y posteriormente los envia al servidor remoto de sincronización
  Future<void> syncChanges(
      {required String dataset,
      required String rowID,
      required List<String> columns,
      required List<Object> values}) async {
    var index = 0;
    var changes = <Change>[];

    var dbversion = await _repo.dbVersion();
    var hlc = HLC.now(_config.deviceId);

    for (var column in columns) {
      changes.add(Change.create(
          column: column,
          value: values[index],
          dataset: dataset,
          rowId: rowID,
          version: dbversion,
          hlc: hlc.pack()));

      hlc.increment();
      index++;
    }

    _addLocalChanges.request.changes = changes;
    await _addLocalChanges.exec();
  }

  /// Inicia la escucha de nuevos cambios en el servidor remoto
  Future<void> initListening() async {
    _obtainRemoteChanges.request.interval = _config.pullInterval;
    await _obtainRemoteChanges.exec();
  }

  /// Detiene la escucha de nuevos cambios en el servidor remoto
  stopListening() {
    _obtainRemoteChanges.stop();
  }
}
