import 'dart:math';

import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/sync/adapter/enviar_eventos_request.dart';
import 'package:eleventa/modulos/sync/adapter/sync_repository.dart';
import 'package:eleventa/modulos/sync/adapter/sync_server.dart';
import 'package:eleventa/modulos/sync/entity/evento.dart';
import 'package:eleventa/modulos/sync/entity/queue_entry.dart';
import 'package:eleventa/modulos/sync/interfaces/sync_server.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:eleventa/modulos/sync/usecase/obtener_eventos_remotos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hlc/hlc.dart';

import '../loader_for_tests.dart';

void main() async {
  late SyncConfig config;
  late Sync syncEngine;
  late SyncRepository syncRepo;
  late IServidorSync servidorSync;

  void initializeSyncConfigForTest() {
    config = SyncConfig(
      dbVersion: appConfig.dbVersion,
      userId: 'AlexGamboa',
      groupId: 'CH00017',
      deviceId: 'iMac27-Caja-${Random().nextInt(10000)}',
      pullInterval: 15000,
      queueInterval: 10000,
      //TODO: usar variables de entorno
      addChangesEndpoint:
          'https://cug3d1zh2k.execute-api.us-west-1.amazonaws.com/prod/agregar-eventos',
      getChangesEndpoint:
          'https://cug3d1zh2k.execute-api.us-west-1.amazonaws.com/prod/obtener-eventos',
      deleteChangesEndpoint: 'deleteEndpointExample.com',
      sendChangesInmediatly: true,
      timeout: const Duration(seconds: 5),
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
    servidorSync = SyncServer();
  });

  test('Debe enviar enventos a nube', () async {
    final rowId = UID().toString();
    final codigo = 'Codigo-${Random().nextInt(10000)}';

    final evento = EventoSync(
      rowId: rowId,
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

    evento.hlc = HLC.now(config.deviceId);

    Object? error;

    try {
      await servidorSync.enviarEvento(evento);
    } catch (e) {
      error = e;
    }

    expect(error, isNull);
  }, skip: true);

  test(
      'Debe recibir eventos de nube posteriores a la ultima fecha de sincronizacion',
      () async {
    const ultimaSync = 1680052022616;

    final response = await servidorSync.obtenerEventos(ultimaSync);

    expect(response, isNotNull);
    expect(response.eventos.length, greaterThan(0));
    expect(response.epochDeSincronizacion, greaterThan(ultimaSync));

    final obtenerEventos =
        ObtenerEventosRemotos(repoSync: syncRepo, servidorSync: servidorSync);

    obtenerEventos.req.singleRequest = true;
    await obtenerEventos.exec();

    //Obtenerla del repo para ver que se guardo.
    final fechaDb = await syncRepo.obtenerUltimaFechaDeSincronizacion();

    expect(ultimaSync, lessThan(fechaDb));
  }, skip: true);

  test('Debe manejar el queue de eventos', () async {
    syncEngine.stopQueueProcessing();

    final rowId = UID().toString();
    final codigo = 'Codigo-${Random().nextInt(10000)}';

    final evento = EventoSync(
      rowId: rowId,
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

    evento.hlc = HLC.now(config.deviceId);

    var req = EnviarEventosRequest(eventos: [evento]);

    final entradaQueue =
        QueueEntry(uid: UID().toString(), body: req.body, headers: req.headers);

    await syncRepo.agregarEntradaQueue(entradaQueue);

    //obtener la entrada de la base de datos para validar que se guardo
    final entradaDb = await syncRepo.obtenerQueue();

    expect(entradaDb, isNotEmpty);

    //procesar el evento
    await syncEngine.initQueueProcessing();

    await Future.delayed(const Duration(seconds: 4));

    //validar que se vacio el queue
    final entradaDb2 = await syncRepo.obtenerQueue();

    expect(entradaDb2, isEmpty);
  }, skip: true);
}
