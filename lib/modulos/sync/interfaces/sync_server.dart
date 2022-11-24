import 'package:eleventa/modulos/sync/change.dart';

abstract class IServidorSync {
  Future<List<Change>> obtenerCambios(
      String groupId, String merkle, String hash);

  Future<void> enviarCambios(List<Change> changes);
}
