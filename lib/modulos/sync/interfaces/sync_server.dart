import 'package:eleventa/modulos/sync/entity/evento.dart';

abstract class IObtenerEventosResponse {
  late final List<EventoSync> eventos;
  late final int epochDeSincronizacion;
}

abstract class IServidorSync {
  Future<IObtenerEventosResponse> obtenerEventos(int ultimaSincronizacion);

  Future<void> enviarEvento(EventoSync evento);
  Future<void> enviarRaw({
    required String body,
    required Map<String, String> headers,
  });
}
