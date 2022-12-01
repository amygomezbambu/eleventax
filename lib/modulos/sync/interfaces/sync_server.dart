import 'package:eleventa/modulos/sync/entity/change.dart';

abstract class IServidorSync {
  Future<List<Change>> obtenerCambios(
      String groupId, String merkle, String hash);

  Future<void> enviarCambios(List<Change> changes);
  Future<void> enviarPayload(String payload);

  String changesToJsonPayload(List<Change> changes);

  List<Change> jsonPayloadToChanges(String payload);
}
