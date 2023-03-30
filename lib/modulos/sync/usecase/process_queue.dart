import 'dart:async';

import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';

class ProcessQueueRequest {
  ///El queue se leerá y procesará periodicamente dependiendo de este valor
  Duration intervalo = const Duration(seconds: 10);
}

class ProcessQueue {
  final IRepositorioSync _repo;
  final IServidorSync _server;

  ProcessQueue({
    required IRepositorioSync repo,
    required IServidorSync server,
  })  : _repo = repo,
        _server = server;

  Timer? _timer;
  final req = ProcessQueueRequest();

  Future<void> exec() async {
    await _reintentarEnvio();
    await _iniciarReintentoPeriodico();
  }

  void detener() {
    _timer?.cancel();
  }

  Future<void> _iniciarReintentoPeriodico() async {
    _timer = Timer.periodic(req.intervalo, (timer) async {
      await _reintentarEnvio();
    });
  }

  Future<void> _reintentarEnvio() async {
    var entradas = await _repo.obtenerQueue();

    for (var entrada in entradas) {
      await _server.enviarRaw(
        body: entrada.body,
        headers: entrada.headers,
      );
      await _repo.borrarEntradaQueue(entrada.uid);
    }
  }
}
