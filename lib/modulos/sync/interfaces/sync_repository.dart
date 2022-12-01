import 'package:eleventa/modulos/sync/entity/change.dart';
import 'package:eleventa/modulos/sync/entity/queue_entry.dart';
import 'package:eleventa/modulos/sync/entity/unique_duplicate.dart';

abstract class IRepositorioSync {
  Future<String> obtenerMerkle();
  Future<String> obtenerHLCActual();
  Future<UniqueDuplicate> obtenerDuplicado(String uid);
  Future<int> obtenerVersionDeDB();
  Future<List<Change>> obtenerCambiosParaRow(String rowId);
  Future<int> obtenerNumeroDeCambiosMasRecientes(Change change);
  Future<List<Change>> obtenerCambiosNoAplicados();
  Future<List<Change>> obtenerTodosLosCambios();
  Future<Change?> obtenerCambioPorHLC(String hlcSerializado);

  Future<Object?> obtenerColumnaDeDataset({
    required String dataset,
    required String column,
    required String uid,
  });

  Future<List<QueueEntry>> obtenerQueue();

  Future<void> actualizarHLCActual(String hlc);
  Future<void> actualizarMerkle(String merkleSerializado);

  Future<void> agregarCambio(Change cambio);

  Future<void> agregarEntradaQueue(QueueEntry entrada);

  Future<void> ejecutarComandoRaw(String command, List<Object?> params);

  Future<Map<String, String>?> obtenerCRDTPorDatos(
    String dataset,
    String column,
    String value,
    String excluirUID,
  );

  Future<void> borrarMerkle();
  Future<void> borrarEntradaQueue(String uid);

  Future<bool> existeRow(String dataset, String rowId);

  Future<void> marcarCambioComoAplicado(Change change);
}
