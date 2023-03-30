import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/notificaciones/domain/notificacion_sync.dart';
import 'package:eleventa/modulos/notificaciones/modulo_notificaciones.dart';
import 'package:eleventa/modulos/notificaciones/usecases/crear_notificacion.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/sync_container.dart';
import 'package:hlc/hlc.dart';

/// Controla la aplicacion de los cambios a la base de datos
///
/// Decide si un cambio debe ser aplicado o descartado
class CRDTAdapter {
  final IRepositorioSync _repo;
  final crearNotificacion = ModuloNotificaciones.crearNotificacion();

  CRDTAdapter([IRepositorioSync? syncRepo])
      : _repo = syncRepo ?? SyncContainer.repositorioSync();

  Future<void> aplicarEventosPendientes() async {
    //TODO: refactor para hacer mas legible, aclarar logica

    var eventos = await _repo.obtenerEventosNoAplicados();

    for (var evento in eventos) {
      for (var campo in evento.campos) {
        var huboConflicto = await procesarUniques(evento, campo);

        if (!huboConflicto) {
          var numeroDeCambiosMasNuevos =
              await _repo.obtenerNumeroDeCambiosMasRecientesParaCampo(
                  evento, campo.nombre);

          if (numeroDeCambiosMasNuevos == 0) {
            await _aplicarCampo(evento, campo);
          }
        }
      }

      await _actualizarHLC(evento.hlc.pack());

      await _repo.marcarEventoComoAplicado(evento);
    }
  }

  /// Busca si el campo tiene una regla de unique, si la tiene busca si hay
  /// algun conflicto con otro registro, si no hay conflicto se retorna false,
  /// si hay conflicto se procesa y aplica el campo y se retorna true
  Future<bool> procesarUniques(EventoSync evento, CampoEventoSync campo) async {
    var hayConflicto = false;

    for (var rule in syncConfig!.uniqueRules) {
      if (rule.dataset == evento.dataset && rule.column == campo.nombre) {
        var currentCRDTValues = await _repo.obtenerCRDTPorDatos(
            evento.dataset, campo.nombre, campo.valor, evento.rowId);

        if (currentCRDTValues != null) {
          hayConflicto = true;

          var dbHLC = HLC.unpack(currentCRDTValues['hlc']!);
          var changeHLC = evento.hlc;

          String sucedioPrimero;
          String sucedioDespues;

          if (dbHLC.compareTo(changeHLC) < 0) {
            sucedioPrimero = currentCRDTValues['rowId']!;
            sucedioDespues = evento.rowId;
          } else {
            sucedioPrimero = evento.rowId;
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
          await _aplicarCampo(evento, campo);

          //marcar el cambio local como bloqueado
          command = 'update ${evento.dataset} set bloqueado = ? where uid = ?;';

          await _repo.ejecutarComandoRaw(command, [true, sucedioDespues]);

          crearNotificacion.req.notificacion = NotificacionSync.crear(
            uidDuplicados: duplicadoUID,
            tipo: TipoNotificacion.conflictoSync,
            mensaje:
                'Se ha detectado un duplicado en [${evento.dataset}:${campo.nombre}]',
          );

          //TODO: esto no se puede manejar desde aqui porque es un caso de uso
          //si se manda llamar provoca un conflicto de sqlite por usar transacciones
          //dentro de otra transaccion
          //explorar que el adaptador retorne una respuesta y si hubo notificaciones
          //que se procesen en la capa de aplicacion
          //await crearNotificacion.exec();
        }

        break;
      }
    }

    return hayConflicto;
  }

  Future<void> _aplicarCampo(EventoSync evento, CampoEventoSync campo) async {
    var command = '';
    var rowExist = await _repo.existeRow(evento.dataset, evento.rowId);

    if (!rowExist) {
      command =
          'insert into ${evento.dataset}(uid,${campo.nombre}) values(?,?);';

      await _repo.ejecutarComandoRaw(command, [evento.rowId, campo.valor]);
    } else {
      command =
          'update ${evento.dataset} set ${campo.nombre} = ? where uid = ?;';

      await _repo.ejecutarComandoRaw(command, [campo.valor, evento.rowId]);
    }
  }

  Future<void> _actualizarHLC(String eventoHLC) async {
    HLC hlcEvento = HLC.unpack(eventoHLC);

    var hlcDb = await _repo.obtenerHLCActual();

    if (hlcDb.isEmpty) {
      await _repo.actualizarHLCActual(hlcEvento.pack());
    } else {
      var localHLC = HLC.unpack(hlcDb);

      if (localHLC.compareTo(hlcEvento) < 0) {
        await _repo.actualizarHLCActual(hlcEvento.pack());
      }
    }
  }
}
