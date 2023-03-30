import 'package:eleventa/modulos/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/entity/merkle.dart';
import 'package:hlc/hlc.dart';

class AplicarEventoLocalmente {
  final IRepositorioSync _repoSync;
  final _crdtAdapter = CRDTAdapter();

  late EventoSync _evento;

  var merkle = Merkle();
  late HLC hlc;

  AplicarEventoLocalmente({required IRepositorioSync repoSync})
      : _repoSync = repoSync;

  Future<void> exec(EventoSync evento) async {
    _evento = evento;

    //var cambios = evento.generarCambios();

    //TODO: modificar algoritmo para que primero persista todo,
    //luego aplique todo y luego envie todo, si falla la aplicacion
    //se reintenta, si falla el envio se reintenta, el envio no es determinante
    //pero la aplicacion si, si no se puede aplicar truena todo.

    await obtenerMerkle()
        .then((_) => actualizarHLC())
        .then((_) => _repoSync.agregarEvento(_evento))
        .then((_) => _crdtAdapter.aplicarEventosPendientes())
        .then((_) => _repoSync.actualizarMerkle(merkle.serialize()));

    // await actualizarHLC();
    // await persistirDatos();
    // await aplicarEvento();
    // await persistirMerkle();
  }

  Future<void> obtenerMerkle() async {
    var serializedMerkle = await _repoSync.obtenerMerkle();

    if (serializedMerkle.isEmpty) {
      merkle = Merkle();
    } else {
      merkle.deserialize(serializedMerkle);
    }
  }

  Future<void> actualizarHLC() async {
    var packedHLC = await _repoSync.obtenerHLCActual();

    if (packedHLC.isEmpty) {
      hlc = HLC.now(_evento.dispositivoID);
    } else {
      _actualizarHLC(packedHLC);
    }

    _evento.hlc = hlc;
    merkle.addTimeStamp(_evento.timestamp);
  }

  void _actualizarHLC(String packedHLC) async {
    HLC newHLC = HLC.now(_evento.dispositivoID);
    HLC currentHLC = HLC.unpack(packedHLC);

    if (currentHLC.compareTo(newHLC) < 0) {
      //newHLC es mayor que currentHLC
      hlc = newHLC;
    } else {
      hlc = currentHLC.increment();
    }
  }
}
