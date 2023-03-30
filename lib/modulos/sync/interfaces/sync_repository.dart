import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/entity/queue_entry.dart';
import 'package:eleventa/modulos/sync/entity/unique_duplicate.dart';

abstract class IRepositorioSync {
  Future<String> obtenerMerkle();
  Future<int> obtenerUltimaFechaDeSincronizacion();
  Future<String> obtenerHLCActual();
  Future<UniqueDuplicate> obtenerDuplicado(String uid);
  Future<int> obtenerNumeroDeCambiosMasRecientesParaCampo(
      EventoSync evento, String campo);
  Future<List<EventoSync>> obtenerEventosNoAplicados();
  Future<EventoSync?> obtenerEventoPorHLC(String hlcSerializado);

  Future<Object?> obtenerColumnaDeDataset({
    required String dataset,
    required String column,
    required String uid,
  });

  Future<List<QueueEntry>> obtenerQueue();

  Future<void> actualizarHLCActual(String hlc);
  Future<void> actualizarMerkle(String merkleSerializado);
  Future<void> actualizarFechaDeSincronizacion(int epoch);

  Future<void> agregarEvento(EventoSync evento);

  Future<void> agregarEntradaQueue(QueueEntry entrada);

  Future<void> ejecutarComandoRaw(String command, List<Object?> params);

  Future<Map<String, String>?> obtenerCRDTPorDatos(
    String dataset,
    String column,
    String value,
    String uidExcluido,
  );

  Future<void> borrarMerkle();
  Future<void> borrarEntradaQueue(String uid);

  Future<bool> existeRow(String dataset, String rowId);

  Future<void> marcarEventoComoAplicado(EventoSync evento);
}
