import 'package:eleventa/modulos/sync/change.dart';
import 'package:eleventa/modulos/sync/unique_duplicate.dart';

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

  Future<void> actualizarHLCActual(String hlc);
  Future<void> actualizarMerkle(String merkleSerializado);

  Future<void> agregarCambio(Change cambio);

  Future<void> ejecutarComandoRaw(String command, List<Object?> params);

  Future<Map<String, String>?> obtenerCRDTPorDatos(
    String dataset,
    String column,
    String value,
    String excluirUID,
  );

  Future<void> borrarMerkle();

  Future<bool> existeRow(String dataset, String rowId);

  Future<void> marcarCambioComoAplicado(Change change);
}
