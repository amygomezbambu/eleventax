import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/adapter/sync_server.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

import '../../loader_for_tests.dart';

void main() async {
  SyncConfig config = SyncConfig(
    dbVersionTable: 'migrations',
    dbVersionField: 'version',
    groupId: 'CH003',
    deviceId: 'caja1',
    pullInterval: 5000,
    addChangesEndpoint:
        'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync',
    getChangesEndpoint:
        'https://qgfy59gc83.execute-api.us-west-1.amazonaws.com/dev/sync-get-changes',
    deleteChangesEndpoint: 'http://localhost:3000/sync-delete-changes',
    sendChangesInmediatly: true,
  );

  config.registerUniqueRule(
    dataset: 'productos',
    uniqueColumn: 'codigo',
  );

  late Sync syncEngine;

  setUpAll(() async {
    var loader = TestsLoader();
    await loader.iniciar();

    syncEngine = Sync(config: config);
    //nock.init();
  });

  setUp(() {
    //nock.cleanAll();
  });

  group('Sync', () {
    /// Sincronzar los cambios locales con el servidor remoto significa varias cosas
    ///
    /// 1. Debe generar los cambios (entradas del CRDT) a partir de los campos y persistirlos
    /// 2. Debe aplicar los cambios a la base de datos local
    /// 3. Debe enviar los cambios al servidor remoto

    test('Debe sincronizar los cambios locales con el servidor remoto',
        () async {
      var syncRepo = SyncRepository();

      var client = MockClient(
        (request) async {
          switch (request.method.toUpperCase()) {
            case 'POST':
              return Response('', 200);
            default:
              return Response('', 500);
          }
        },
      );

      syncEngine = Sync(
        config: config,
        servidorSync: SyncServer(client: client),
      );

      var ocurrioError = false;
      var productoUID = UID();

      try {
        await syncEngine.synchronize(
          dataset: 'productos',
          rowID: productoUID.toString(),
          fields: {'codigo': '12345', 'nombre': 'yo NO debo de ganar'},
        );
      } catch (e) {
        ocurrioError = true;
      }

      expect(ocurrioError, false);

      //1
      var existeCRDTRow =
          await syncRepo.existeRow('productos', productoUID.toString());

      expect(existeCRDTRow, true);
    });

    test('Debe obtener los cambios mas recientes del servidor remoto',
        () async {});

    test('Debe aplicar el metodo de resolución en caso de uniques repetidos',
        () async {});

    /// Si no se reciben correctamente (no hay respuesta 200) entonces deben mantenerse
    /// en un Queue local para reintentar posteriormente
    ///
    /// Si se reciben correctamente (respuesta 200) se remueven del Queue
    test(
        'Debe manejar un queue local para los mensajes que no se pudieron sincronizar',
        () async {});

    test('Debe resolver un conflicto manualmente segun selección del usuario',
        () async {});

    // test('Debe mergear los cambios si recibe un producto con codigo repetido',
    //     () async {
    //   syncEngine =
    //       Sync(config: config, servidorSync: SyncContainer.servidorSync());

    //   var syncRepo = SyncRepository();
    //   var productosRepo = RepositorioProductos(
    //       syncAdapter: syncEngine, db: Dependencias.infra.database());
    //   var crdt = CRDTAdapter();

    //   var uidLocal = UID();
    //   var uidRemoto = UID();

    //   var codigoDuplicado = '12345a';

    //   // Simulamos a un dispositivo local que genera un producto offline.
    //   await syncEngine.synchronize(
    //     dataset: 'productos',
    //     rowID: uidLocal.toString(),
    //     fields: {'codigo': codigoDuplicado, 'nombre': 'yo debo de ganar'},
    //   );

    //   // 2. Generando una entidad producto desde "otro dispisitivo" offline
    //   var server = SyncServer();
    //   var changes = <Change>[];
    //   var rowId = uidRemoto.toString();
    //   var remoteNode = 'Dispositivo ID Inventado';
    //   var remoteHLC = HLC(
    //       timestamp: DateTime.now().millisecondsSinceEpoch + 100000,
    //       count: 0,
    //       node: remoteNode);

    //   changes.add(Change.load(
    //       column: 'codigo',
    //       value: codigoDuplicado,
    //       dataset: 'productos',
    //       rowId: rowId,
    //       hlc: remoteHLC.pack(),
    //       version: 4));

    //   var newHLC = remoteHLC.increment();

    //   changes.add(Change.load(
    //       column: 'nombre',
    //       value: 'yo NO debo de ganar',
    //       dataset: 'productos',
    //       rowId: rowId,
    //       hlc: newHLC.pack(),
    //       version: 4));

    //   await server.enviarCambios(changes);
    //   // 2.3 - Recibimos los mensajes del servidory los aplicamos localmente
    //   await Future.delayed(const Duration(seconds: 3));

    //   // 2.1 - Recibir los mensajes actualizados del servidor, para aplicar lo que hizo
    //   // el "otro dispositivo" en nuestro dispositivo local
    //   var serializedMerkle = await syncRepo.obtenerMerkle();
    //   var merkle = Merkle();
    //   var hash = '';

    //   if (serializedMerkle.isNotEmpty) {
    //     merkle.deserialize(serializedMerkle);
    //     hash = merkle.tree!.hash.toString();
    //   }

    //   var changesFromServer =
    //       await server.obtenerCambios(config.groupId, serializedMerkle, hash);

    //   for (var change in changesFromServer) {
    //     var dbChange = await syncRepo.obtenerCambioPorHLC(change.hlc);

    //     if (dbChange == null) {
    //       await syncRepo.agregarCambio(change);
    //     }
    //   }

    //   await crdt.applyPendingChanges();

    //   var local = await productosRepo.obtenerNombreYCodigo(uidLocal);
    //   var remoto = await productosRepo.obtenerNombreYCodigo(uidRemoto);

    //   //Comprobamos que la entidad mas antigua gana y la duplicada se marca como
    //   //bloqueada
    //   expect(local['bloqueado'] as int, 0);
    //   expect(remoto['bloqueado'] as int, 1);

    //   //Aplicar resolución de conflicto
    //   var resolverConflicto = ResolveConflict();

    //   var datosDuplicado =
    //       await syncRepo.obtenerDuplicadoPorSucedioPrimero(uidLocal.toString());

    //   var request = ResolveConflictRequest(
    //       uid: datosDuplicado.uid, resolution: SyncConflictResolution.firstWin);

    //   await resolverConflicto.exec(request);

    //   local = await productosRepo.obtenerNombreYCodigo(uidLocal);
    //   remoto = await productosRepo.obtenerNombreYCodigo(uidRemoto);

    //   //Como aplicamos firstWin el segundo en suceder se marca como borrado
    //   expect(remoto['borrado'] as int, 1);
    // });
  });
}
