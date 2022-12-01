import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/sync/usecase/add_local_changes.dart';
import 'package:eleventa/modulos/sync/usecase/process_queue.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/entity/queue_entry.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:eleventa/modulos/sync/sync_container.dart';
import 'package:hlc/hlc.dart';

import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/sync/usecase/obtain_remote_changes.dart';
import 'package:eleventa/modulos/sync/entity/change.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';

/// Clase principal de Sincronización
///
/// A travez de esta clase se accede a todos los servicios de sincronización
class Sync implements ISync {
  late IRepositorioSync _repoSync;
  late IServidorSync _servidorSync;

  late ObtainRemoteChanges _obtainRemoteChanges;
  late ProcessQueue _processQueue;
  late AddLocalChanges _addLocalChanges;

  static final Sync _instance = Sync._internal();

  factory Sync({
    required SyncConfig config,
    IRepositorioSync? repoSync,
    IServidorSync? servidorSync,
  }) {
    var instance = _instance;

    //Esta linea debe ejecutarse antes que todo para registrar la config de manera global
    syncConfig = config;

    instance._repoSync = repoSync ?? SyncContainer.repositorioSync();
    instance._servidorSync = servidorSync ?? SyncContainer.servidorSync();

    instance._addLocalChanges = AddLocalChanges(repoSync: instance._repoSync);
    instance._obtainRemoteChanges = ObtainRemoteChanges(
      repoSync: instance._repoSync,
      servidorSync: instance._servidorSync,
    );

    instance._processQueue = ProcessQueue(
      repo: instance._repoSync,
      server: instance._servidorSync,
    );

    return instance;
  }

  Sync._internal();

  static Sync getInstance() {
    if (syncConfig == null) {
      throw EleventaEx(
          message: 'El modulo de sincronización no ha sido inicializado\n'
              'Debes mandar llamas Sync(config) antes de poder obtener una instancia');
    }

    return _instance;
  }

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
    try {
      var changes = await _generateChanges(
        dataset,
        rowID,
        _sanitizarFields(fields),
      );

      await _applyChangesToLocalDatabase(changes);
      //TODO: esta linea es la que hace que la UI se tarde demasiado al guardar un producto
      await _sendChangesToRemoteServer(changes);
    } catch (e, stack) {
      if (syncConfig?.onError != null) {
        syncConfig?.onError!(e, stack);
      }
    }
  }

  Map<String, Object?> _sanitizarFields(Map<String, Object?> fields) {
    Map<String, Object?> nuevosFields = {};
    for (var key in fields.keys) {
      nuevosFields[key] = fields[key] is bool
          ? Utils.db.boolToInt(fields[key] as bool)
          : fields[key];
    }

    return nuevosFields;
  }

  @override
  Future<void> initListening() async {
    _obtainRemoteChanges.req.interval = syncConfig!.pullInterval;
    await _obtainRemoteChanges.exec();
  }

  @override
  void stopListening() {
    _obtainRemoteChanges.stop();
  }

  Future<void> _sendChangesToRemoteServer(List<Change> changes) async {
    if (syncConfig!.sendChangesInmediatly) {
      try {
        await _servidorSync.enviarCambios(changes);
      } catch (e) {
        await _repoSync.agregarEntradaQueue(
          QueueEntry(
            uid: UID().toString(),
            payload: _servidorSync.changesToJsonPayload(changes),
          ),
        );

        rethrow;
      }
    }
  }

  Future<void> _applyChangesToLocalDatabase(List<Change> changes) async {
    _addLocalChanges.req.changes = changes;
    await _addLocalChanges.exec();
  }

  Future<List<Change>> _generateChanges(
    String dataset,
    String rowID,
    Map<String, Object?> fields,
  ) async {
    var changes = <Change>[];

    var dbversion = await _repoSync.obtenerVersionDeDB();
    var hlc = HLC.now(syncConfig!.deviceId);

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

  @override
  Future<void> initQueueProcessing() async {
    _processQueue.req.retryInterval =
        Duration(milliseconds: syncConfig!.queueInterval);

    await _processQueue.exec();
  }

  @override
  void stopQueueProcessing() {
    _processQueue.detener();
  }
}
