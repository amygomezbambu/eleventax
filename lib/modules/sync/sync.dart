import 'package:eleventa/modules/common/app/interface/sync.dart';
import 'package:eleventa/modules/sync/adapter/sync_repository.dart';
import 'package:eleventa/modules/sync/adapter/sync_server.dart';
import 'package:eleventa/modules/sync/app/usecase/add_local_changes.dart';
import 'package:eleventa/modules/sync/app/usecase/obtain_remote_changes.dart';
import 'package:eleventa/modules/sync/change.dart';
import 'package:eleventa/modules/sync/error.dart';
import 'package:eleventa/modules/sync/sync_config.dart';
import 'package:hlc/hlc.dart';

/// Clase principal de Sincronización
///
/// A travez de esta clase se accede a todos los servicios de sincronización
class Sync implements ISync {
  late SyncConfig _config;

  var _initialized = false;

  final _repo = SyncRepository();
  final _syncServer = SyncServer();
  final _obtainRemoteChanges = ObtainRemoteChanges();
  final _addLocalChanges = AddLocalChanges();

  // #region singleton
  static final Sync _instance = Sync._internal();

  factory Sync.create({required SyncConfig syncConfig}) {
    var instance = _instance;
    instance._config = syncConfig;
    instance._initialized = true;

    return instance;
  }

  factory Sync.get() {
    if (!_instance._initialized) {
      throw SyncError('No se ha inicializado el modulo de Sincronización', '');
    }

    return _instance;
  }

  Sync._internal();
  // #endregion

  /// Sincroniza los cambios.
  ///
  /// Para cada columna en [columns] y su respectivo valor en [values]
  /// aplica los cambios a la base de datos local en la tabla [dataset] y
  /// el row [rowID] y posteriormente los envia al servidor remoto de sincronización
  @override
  Future<void> synchronize({
    required String dataset,
    required String rowID,
    required Map<String, Object?> fields,
  }) async {
    var changes = await _generateChanges(dataset, rowID, fields);
    await _applyChangesToLocalDatabase(changes);
    await _sendChangesToRemoteServer(changes);
  }

  /// Inicia la escucha de nuevos cambios en el servidor remoto
  @override
  Future<void> initListening() async {
    _obtainRemoteChanges.request.interval = _config.pullInterval;
    await _obtainRemoteChanges.exec();
  }

  /// Detiene la escucha de nuevos cambios en el servidor remoto
  @override
  void stopListening() {
    _obtainRemoteChanges.stop();
  }

  Future<void> _sendChangesToRemoteServer(List<Change> changes) async {
    if (_config.sendChangesInmediatly) {
      await _syncServer.send(changes);
    }
  }

  Future<void> _applyChangesToLocalDatabase(List<Change> changes) async {
    _addLocalChanges.request.changes = changes;
    await _addLocalChanges.exec();
  }

  Future<List<Change>> _generateChanges(
    String dataset,
    String rowID,
    Map<String, Object?> fields,
  ) async {
    var changes = <Change>[];

    var dbversion = await _repo.dbVersion();
    var hlc = HLC.now(_config.deviceId);

    for (var field in fields.keys) {
      changes.add(Change.create(
          column: field,
          value: fields[field],
          dataset: dataset,
          rowId: rowID.toString(),
          version: dbversion,
          hlc: hlc.pack()));

      hlc.increment();
    }

    return changes;
  }
}
