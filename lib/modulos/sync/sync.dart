import 'dart:async';

import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/sync/adapter/enviar_eventos_request.dart';
import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/usecase/aplicar_evento_localmente.dart';
import 'package:eleventa/modulos/sync/usecase/process_queue.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/entity/queue_entry.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:eleventa/modulos/sync/sync_container.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/sync/usecase/obtener_eventos_remotos.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';

/// Clase principal de Sincronización
///
/// A travez de esta clase se accede a todos los servicios de sincronización
class Sync implements ISync {
  late IRepositorioSync _repoSync;
  late IServidorSync _servidorSync;

  late ObtenerEventosRemotos _obtainRemoteChanges;
  late ProcessQueue _processQueue;
  late AplicarEventoLocalmente _aplicarEventoLocalmente;

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

    instance._aplicarEventoLocalmente =
        AplicarEventoLocalmente(repoSync: instance._repoSync);
    instance._obtainRemoteChanges = ObtenerEventosRemotos(
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
      throw SyncEx(
          tipo: TiposSyncEx.noInicializado,
          message: 'El modulo de sincronización no ha sido inicializado\n'
              'Debes mandar llamas Sync(config) antes de poder obtener una instancia');
    }

    return _instance;
  }

  /// Sincroniza los cambios.
  ///
  /// Para cada campo en [fields]
  /// aplica los cambios a la base de datos local en la tabla [dataset] y
  /// el row [rowID] y posteriormente los envia al servidor remoto de sincronización
  ///
  /// Si se desea que el proceso espere hasta que reciba respuesta del servidor se
  /// debe establecer [awaitServerResponse] a true, el comportamiento default es no esperar
  /// por lo que este proceso retornará inmediatamente despues de aplicar los cambios en
  /// la base de datos y el envio se quedara en background.
  @override
  Future<void> sincronizar({
    TipoEventoSync tipo = TipoEventoSync.actualizar,
    required String rowID,
    required String dataset,
    required Map<String, Object?> campos,
    bool awaitServerResponse = false,
  }) async {
    try {
      campos = _sanitizarFields(campos);

      var camposSync = campos.entries
          .map(
            (e) => CampoEventoSync.crear(
              nombre: e.key,
              valor: e.value,
            ),
          )
          .toList();

      var evento = EventoSync(
        tipo: tipo,
        rowId: rowID,
        dispositivoID: syncConfig!.deviceId,
        usuarioUID: syncConfig!.userUID,
        dataset: dataset,
        campos: camposSync,
        version: syncConfig!.dbVersion,
      );

      await _aplicarEventoLocalmente.exec(evento);

      if (awaitServerResponse) {
        await _enviarEventoANube(evento);
      } else {
        unawaited(_enviarEventoANube(evento));
      }
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

    //TODO: validar que todos los tipos sean primitivos, no se pueden enviar objetos

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

  Future<void> _enviarEventoANube(EventoSync evento) async {
    if (syncConfig!.sendChangesInmediatly) {
      try {
        await _servidorSync.enviarEvento(evento);
      } catch (e) {
        final request = EnviarEventosRequest(eventos: [evento]);
        await _repoSync.agregarEntradaQueue(
          QueueEntry(
            uid: UID().toString(),
            body: request.body,
            headers: request.headers,
          ),
        );

        rethrow;
      }
    }
  }

  @override
  Future<void> initQueueProcessing() async {
    _processQueue.req.intervalo =
        Duration(milliseconds: syncConfig!.queueInterval);

    await _processQueue.exec();
  }

  @override
  void stopQueueProcessing() {
    _processQueue.detener();
  }
}
