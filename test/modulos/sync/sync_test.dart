import 'dart:convert';

import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/adapter/sync_server.dart';
import 'package:eleventa/modulos/sync/config.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/sync_container.dart';
import 'package:eleventa/modulos/sync/usecase/obtener_eventos_remotos.dart';
import 'package:eleventa/modulos/sync/usecase/resolve_conflict.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlc/hlc.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

import '../../loader_for_tests.dart';
import '../../utils/database.dart';

void main() async {
  late SyncConfig config;
  late Sync syncEngine;
  late SyncRepository syncRepo;

  void initializeSyncConfigForTest() {
    config = SyncConfig(
      dbVersion: appConfig.dbVersion,
      userId: 'AlexGamboa',
      groupId: 'CH003',
      deviceId: 'caja1',
      pullInterval: 5000,
      queueInterval: 10000,
      addChangesEndpoint: 'addEndpointExample.com',
      getChangesEndpoint: 'getEndpointExample.com',
      deleteChangesEndpoint: 'deleteEndpointExample.com',
      sendChangesInmediatly: true,
      timeout: const Duration(seconds: 3),
      onError: (e, s) => throw e,
    );

    config.registerUniqueRule(
      dataset: 'productos',
      uniqueColumn: 'codigo',
    );

    config.registerUniqueRule(
      dataset: 'categorias',
      uniqueColumn: 'nombre',
    );
  }

  setUpAll(() async {
    var loader = TestsLoader();
    await loader.iniciar();

    initializeSyncConfigForTest();

    syncEngine = Sync(config: config);
    syncRepo = SyncRepository();
  });

  group('Sync Engine', () {
    /// Sincronzar los cambios locales con el servidor remoto significa varias cosas
    ///
    /// 1. Debe generar los cambios (entradas del CRDT) a partir de los campos y persistirlos
    /// 2. Debe aplicar los cambios a la base de datos local
    /// 3. Debe enviar los cambios al servidor remoto
    test('Debe sincronizar los cambios locales con el servidor remoto',
        () async {
      var response = Response('', 204);
      var productoUID = UID();
      var codigo = '12345';
      var nombre = 'Coca cola';

      var client = MockClient(
        (request) async {
          switch (request.method.toUpperCase()) {
            case 'POST':
              response = Response('', 200);
              return Response('', 200);
            default:
              response = Response('', 500);
              return Response('', 500);
          }
        },
      );

      syncEngine = Sync(
        config: config,
        servidorSync: SyncServer(client: client),
      );

      await syncEngine.sincronizar(
        dataset: 'productos',
        rowID: productoUID.toString(),
        campos: {'codigo': codigo, 'nombre': nombre},
        awaitServerResponse: true,
      );

      var existeCRDTRow =
          await syncRepo.existeRow('productos', productoUID.toString());

      var codigoDb = await syncRepo.obtenerColumnaDeDataset(
        column: 'codigo',
        dataset: 'productos',
        uid: productoUID.toString(),
      );

      //Deben existir los cambios en el CRDT (DB)
      expect(existeCRDTRow, true);
      //Debe estar aplicado el cambio en la base de datos
      expect(codigoDb, codigo);
      //Debe haber enviado los cambios al servidor de sincronización
      expect(response.statusCode, 200);
    });

    test('Debe obtener los cambios mas recientes del servidor remoto',
        () async {
      var productoUID = UID();
      var codigo = '25454454';

      final evento = EventoSync(
        rowId: productoUID.toString(),
        dataset: 'productos',
        version: appConfig.dbVersion,
        dispositivoID: config.deviceId,
        usuarioUID: config.userUID,
        campos: [
          CampoEventoSync.crear(
            nombre: 'nombre',
            valor: 'coca cola 600 ml',
          ),
          CampoEventoSync.crear(
            nombre: 'codigo',
            valor: codigo,
          ),
        ],
      );

      evento.hlc = HLC(
        timestamp: DateTime.now().millisecondsSinceEpoch + 100000,
        count: 0,
        node: 'DispositivoRemoto1',
      );

      final eventoJson = jsonEncode(evento);

      final fechaSync = DateTime.now().millisecondsSinceEpoch;

      var client = MockClient(
        (request) async {
          switch (request.method.toUpperCase()) {
            case 'GET':
              return Response('''{
                "fecha_sincronizacion" : $fechaSync,
                "eventos": [
                    $eventoJson
                ]
              }''', 200);
            default:
              return Response('', 500);
          }
        },
      );

      var obtenerCambiosRemotos = ObtenerEventosRemotos(
        repoSync: SyncContainer.repositorioSync(),
        servidorSync: SyncServer(client: client),
      );

      obtenerCambiosRemotos.req.singleRequest = true;

      await obtenerCambiosRemotos.exec();

      var existeCRDTRow =
          await syncRepo.existeRow('productos', productoUID.toString());

      var codigoDb = await syncRepo.obtenerColumnaDeDataset(
        column: 'codigo',
        dataset: 'productos',
        uid: productoUID.toString(),
      );

      var fechaDb = await syncRepo.obtenerUltimaFechaDeSincronizacion();

      //Deben existir los cambios en el LWWS CRDT (Tabla DB)
      expect(existeCRDTRow, true);
      //Debe estar aplicado el cambio en la base de datos local
      expect(codigoDb, codigo);
      //Debe haber actualizado la fecha de sincronización
      expect(fechaDb, fechaSync);
    });

    /// Si no se reciben correctamente (no hay respuesta 200) entonces deben mantenerse
    /// en un Queue local para reintentar posteriormente
    ///
    /// Al reintentar, si los cambios se reciben correctamente (respuesta 200)
    /// se remueven del Queue
    test(
        'Debe manejar un queue local con los cambios que no se pudieron sincronzar',
        () async {
      var productoUID = UID();
      var codigo = 'abc12342';
      var nombre = 'Coca cola 600ml 2 34';

      var testDbUtils = TestDatabaseUtils();
      await testDbUtils.limpar(tabla: 'crdt');
      await testDbUtils.limpar(tabla: 'crdt_campos');

      var client = MockClient((req) async {
        return Response('', 500);
      });

      final servidor = SyncServer(client: client);

      syncEngine = Sync(
        config: config,
        servidorSync: servidor,
      );

      syncEngine.stopQueueProcessing();

      try {
        await syncEngine.sincronizar(
          dataset: 'productos',
          rowID: productoUID.toString(),
          campos: {'codigo': codigo, 'nombre': nombre},
          awaitServerResponse: true,
        );
      } catch (e) {
        //Nos comemos el error para que no pare las pruebas
      }

      var queueEntries = await syncRepo.obtenerQueue();

      //var response = ObtenerEventosResponse(payload: queueEntries[0].body);

      //Los cambios deben estar en el queue
      expect(queueEntries.length, greaterThan(0));

      //TODO: que probar en este caso
      // expect(
      //   eventos.any((evento) =>
      //       evento.campos. == 'codigo' && (cambio.value as String) == codigo),
      //   true,
      // );

      // expect(
      //   eventos.any((cambio) =>
      //       cambio.column == 'nombre' && (cambio.value as String) == nombre),
      //   true,
      // );

      //ahora probamos que el queue se limpie
      client = MockClient(
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

      await syncEngine.initQueueProcessing();

      queueEntries = await syncRepo.obtenerQueue();

      //debe estar vacio
      expect(queueEntries.length, 0);
    });

    test('Debe resolver un conflicto manualmente segun selección del usuario',
        () async {
      //PARTE 1 generar los cambios locales con un unique duplicado y enviarlos al server
      var productoUID = UID();
      var codigo = '12345abcdef';
      var nombre = 'Coca cola';

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

      await syncEngine.sincronizar(
        dataset: 'productos',
        rowID: productoUID.toString(),
        campos: {'codigo': codigo, 'nombre': nombre},
        awaitServerResponse: true,
      );

      //PARTE 2 recibir cambios del servidor remoto con el mismo unique para provocar el conflicto
      var producto2UID = UID();

      const dispositivoRemoto = 'dispositivo-remoto-1';

      final evento = EventoSync(
        rowId: producto2UID.toString(),
        dataset: 'productos',
        version: appConfig.dbVersion,
        dispositivoID: dispositivoRemoto,
        usuarioUID: config.userUID,
        campos: [
          CampoEventoSync.crear(
            nombre: 'nombre',
            valor: 'Otro producto con el mismo codigo',
          ),
          CampoEventoSync.crear(
            nombre: 'codigo',
            valor: codigo,
          ),
        ],
      );

      evento.hlc = HLC(
        timestamp: DateTime.now().millisecondsSinceEpoch + 100000,
        count: 0,
        node: dispositivoRemoto,
      );

      var client2 = MockClient(
        (request) async {
          switch (request.method.toUpperCase()) {
            case 'GET':
              return Response('''{
                "fecha_sincronizacion" : ${DateTime.now().millisecondsSinceEpoch},
                "eventos" : [${jsonEncode(evento)}]
              }''', 200);
            default:
              return Response('', 500);
          }
        },
      );

      var obtenerCambiosRemotos = ObtenerEventosRemotos(
        repoSync: SyncContainer.repositorioSync(),
        servidorSync: SyncServer(client: client2),
      );

      obtenerCambiosRemotos.req.singleRequest = true;

      await obtenerCambiosRemotos.exec();

      //En este punto deben estar los cambios en la db marcados como bloqueados

      final productosRepo = Dependencias.productos.repositorioProductos();

      var local = await productosRepo.obtenerNombreYCodigo(productoUID);
      var remoto = await productosRepo.obtenerNombreYCodigo(producto2UID);

      //Comprobamos que la entidad mas antigua gana y la duplicada se marca como
      //bloqueada
      expect(local['bloqueado'] as int, 0);
      expect(remoto['bloqueado'] as int, 1);

      //PARTE 3 resolución del conflicto
      var resolverConflicto = ResolveConflict();

      var datosDuplicado = await syncRepo
          .obtenerDuplicadoPorSucedioPrimero(productoUID.toString());

      var request = ResolveConflictRequest(
          uid: datosDuplicado.uid, resolution: SyncConflictResolution.firstWin);

      await resolverConflicto.exec(request);

      local = await productosRepo.obtenerNombreYCodigo(productoUID);
      remoto = await productosRepo.obtenerNombreYCodigo(producto2UID);

      //Como aplicamos firstWin el segundo en suceder se marca como borrado
      expect(remoto['borrado'] as int, 1);
    });

    test('Debe lanzar un error de timeout si se supera el tiempo configurado',
        () async {
      //TODO: extraer funcion limpiar tablas de sincronización
      var testDbUtils = TestDatabaseUtils();
      await testDbUtils.limpar(tabla: 'crdt');
      await testDbUtils.limpar(tabla: 'crdt_campos');

      var client = MockClient(
        (request) async {
          switch (request.method.toUpperCase()) {
            case 'POST':
              //esta linea probocara que el cliente no responda durante timeout + 1 segundos
              //es decir forzará el timout
              await Future.delayed(
                  syncConfig!.timeout + const Duration(seconds: 1));
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

      SyncEx? ex;

      try {
        await syncEngine.sincronizar(
          dataset: 'productos',
          rowID: UID().toString(),
          campos: {'codigo': '123fggf4343', 'nombre': 'coca cola'},
          awaitServerResponse: true,
        );
      } catch (e) {
        if (e is SyncEx) {
          ex = e;
        }
      }

      expect(ex, isNotNull);
      expect(ex!.message.toLowerCase().contains('timeout'), true);
    });
  });
}
