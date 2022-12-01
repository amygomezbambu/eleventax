import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/notificaciones/domain/notificacion_sync.dart';
import 'package:eleventa/modulos/notificaciones/modulo_notificaciones.dart';
import 'package:eleventa/modulos/notificaciones/usecases/crear_notificacion.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/sync_container.dart';
import 'package:hlc/hlc.dart';
import 'package:eleventa/modulos/sync/entity/change.dart';

/// Controla la aplicacion de los cambios a la base de datos
///
/// Decide si un cambio debe ser aplicado o descartado
class CRDTAdapter {
  final IRepositorioSync _repo;
  final crearNotificacion = ModuloNotificaciones.crearNotificacion();

  CRDTAdapter([IRepositorioSync? syncRepo])
      : _repo = syncRepo ?? SyncContainer.repositorioSync();

  Future<void> applyPendingChanges() async {
    var pendingChanges = await _repo.obtenerCambiosNoAplicados();

    for (var change in pendingChanges) {
      await processUniques(change);

      var newerChangesCount =
          await _repo.obtenerNumeroDeCambiosMasRecientes(change);

      if (newerChangesCount == 0) {
        await _applyChange(change);
        await _updateHLC(change.hlc);
      } else {
        await _discardChange(change);
      }
    }
  }

  Future<void> processUniques(Change change) async {
    for (var rule in syncConfig!.uniqueRules) {
      if (rule.dataset == change.dataset && rule.column == change.column) {
        var currentCRDTValues = await _repo.obtenerCRDTPorDatos(
            rule.dataset, rule.column, change.value as String, change.rowId);

        if (currentCRDTValues != null) {
          if (currentCRDTValues['rowId']! == change.rowId) {
            continue;
          }

          var dbHLC = HLC.unpack(currentCRDTValues['hlc']!);
          var changeHLC = HLC.unpack(change.hlc);

          String sucedioPrimero;
          String sucedioDespues;

          if (dbHLC.compareTo(changeHLC) < 0) {
            sucedioPrimero = currentCRDTValues['rowId']!;
            sucedioDespues = change.rowId;
          } else {
            sucedioPrimero = change.rowId;
            sucedioDespues = currentCRDTValues['rowId']!;
          }

          var command =
              'insert into sync_duplicados(uid,dataset,column,sucedio_primero,sucedio_despues) '
              'values(?,?,?,?,?)';

          var duplicadoUID = UID();

          await _repo.ejecutarComandoRaw(command, [
            duplicadoUID.toString(),
            rule.dataset,
            rule.column,
            sucedioPrimero,
            sucedioDespues,
          ]);

          //CREAR EL ROW
          await _applyChange(change);

          //marcar el cambio local como bloqueado
          command = 'update ${change.dataset} set bloqueado = ? where uid = ?;';

          await _repo.ejecutarComandoRaw(command, [true, sucedioDespues]);

          crearNotificacion.req.notificacion = NotificacionSync.crear(
            uidDuplicados: duplicadoUID,
            tipo: TipoNotificacion.conflictoSync,
            mensaje:
                'Se ha detectado un duplicado en [${change.dataset}:${change.column}]',
          );

          await crearNotificacion.exec();
        }

        break;
      }
    }
  }

  Future<void> _applyChange(Change change) async {
    var command = '';
    var rowExist = await _repo.existeRow(change.dataset, change.rowId);

    if (!rowExist) {
      command =
          'insert into ${change.dataset}(uid,${change.column}) values(?,?);';

      await _repo.ejecutarComandoRaw(command, [change.rowId, change.value]);
    } else {
      command =
          'update ${change.dataset} set ${change.column} = ? where uid = ?;';

      await _repo.ejecutarComandoRaw(command, [change.value, change.rowId]);
    }

    //marcar el cambio como aplicado
    await _repo.marcarCambioComoAplicado(change);
  }

  Future<void> _discardChange(Change change) async {
    await _repo.marcarCambioComoAplicado(change);
  }

  Future<void> _updateHLC(String changeHLC) async {
    HLC localHLC;
    HLC remoteHLC = HLC.unpack(changeHLC);

    var currentHLC = await _repo.obtenerHLCActual();

    if (currentHLC.isEmpty) {
      await _repo.actualizarHLCActual(remoteHLC.pack());
    } else {
      localHLC = HLC.unpack(currentHLC);

      if (localHLC.compareTo(remoteHLC) < 0) {
        await _repo.actualizarHLCActual(remoteHLC.pack());
      }
    }
  }
}
