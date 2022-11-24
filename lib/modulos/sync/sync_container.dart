import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/adapter/sync_server.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_repository.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';

class SyncContainer {
  static IRepositorioSync repositorioSync() {
    return SyncRepository();
  }

  static IServidorSync servidorSync() {
    return SyncServer();
  }
}
