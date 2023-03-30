import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/remote_config.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';

class SincronizacionLoader {
  static Future<void> iniciar() async {
    final remoteConfig = Dependencias.infra.remoteConfig();
    final syncHabilitada =
        remoteConfig.tieneFeatureFlag(FeatureFlag.sincronizacion);

    var config = SyncConfig(
      dbVersion: appConfig.dbVersion,
      userId: 'AlexGamboa', //TODO: Cambiar por el usuario real
      groupId: 'CH0002', //TODO: Cambiar por el grupo real
      deviceId: appConfig.deviceId.toString(),
      //TODO: usar variables de entorno
      sendChangesInmediatly: syncHabilitada,
      addChangesEndpoint:
          'https://cug3d1zh2k.execute-api.us-west-1.amazonaws.com/prod/agregar-eventos',
      getChangesEndpoint:
          'https://cug3d1zh2k.execute-api.us-west-1.amazonaws.com/prod/obtener-eventos',
      deleteChangesEndpoint: 'http://localhost:3000/sync-delete-changes',
      pullInterval: 30000,
      timeout: const Duration(seconds: 15),
      onError: (ex, stack) {
        Dependencias.infra.logger().error(ex: ex, stackTrace: stack);
        throw ex;
      },
    );

    _registrarUniques(config);

    var syncEngine = Sync(config: config);

    if (syncHabilitada) {
      await syncEngine.initListening();
    }
  }

  ///Registra los uniques constraints para que el motor de sincronización los maneje
  ///
  ///Debido al uso de CRDTs no es posible usar llaves foraneas o uniques directamente
  ///en la base de datos, asi es que el motor debe manejarlos.
  ///
  ///Si se registra un unique el motor detectara cualquier duplicado y por default
  ///marcara los registros en conflicto como bloqueados, posteriormente el usuario debe
  ///determinar el metodo de resolución.
  static void _registrarUniques(SyncConfig config) {
    config.registerUniqueRule(
      dataset: 'productos',
      uniqueColumn: 'codigo',
    );

    config.registerUniqueRule(
      dataset: 'categorias',
      uniqueColumn: 'nombre',
    );
  }
}
