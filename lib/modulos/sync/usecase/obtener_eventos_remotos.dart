import 'dart:async';

import 'package:eleventa/modulos/sync/adapter/crdt_adapter.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';

class ObtenerEventosRemotosRequest {
  var interval = 30000;
  var singleRequest = false;
}

class ObtenerEventosRemotos {
  final IServidorSync _servidorSync;
  final IRepositorioSync _repoSync;

  final req = ObtenerEventosRemotosRequest();

  Timer? _timer;

  final _crdt = CRDTAdapter();

  ObtenerEventosRemotos({
    required IRepositorioSync repoSync,
    required IServidorSync servidorSync,
  })  : _repoSync = repoSync,
        _servidorSync = servidorSync;

  Future<void> exec() async {
    if (req.singleRequest) {
      if (_timer != null && _timer!.isActive) {
        stop();
      }

      var eventos = await _obtenerEventosDelServidor();
      await _persistirEventos(eventos);
      await _crdt.aplicarEventosPendientes();
    } else {
      await _initListening();
    }
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _initListening() async {
    _timer = Timer.periodic(
      Duration(milliseconds: req.interval),
      (timer) async {
        var eventos = await _obtenerEventosDelServidor();
        await _persistirEventos(eventos);
        await _crdt.aplicarEventosPendientes();
      },
    );
  }

  Future<void> _persistirEventos(List<EventoSync> eventos) async {
    for (var evento in eventos) {
      var dbEvento = await _repoSync.obtenerEventoPorHLC(evento.hlc.pack());

      if (dbEvento == null) {
        await _repoSync.agregarEvento(evento);
      }
    }
  }

  Future<List<EventoSync>> _obtenerEventosDelServidor() async {
    var ultimaSincronizacion =
        await _repoSync.obtenerUltimaFechaDeSincronizacion();

    var response = await _servidorSync.obtenerEventos(ultimaSincronizacion);

    await _repoSync
        .actualizarFechaDeSincronizacion(response.epochDeSincronizacion);

    return response.eventos;
  }
}
