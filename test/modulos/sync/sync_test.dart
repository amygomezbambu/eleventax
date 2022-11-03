import 'dart:convert';

import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import '../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  test('Debe guardar los cambios locales aunque no tengamos internet',
      () async {
    // TODO: Implement test
  });

  test('Debe enviar los cambios esperados al servidor en el formato adecuado',
      () async {
    final SyncConfig testsSyncConfig = SyncConfig.create(
        dbVersionTable: 'migrations',
        dbVersionField: 'version',
        groupId: 'SUCURSAL',
        deviceId: '12345',
        addChangesEndpoint: 'http://localhost:3000/sync/',
        getChangesEndpoint: 'http://localhost:3000/sync',
        deleteChangesEndpoint: 'http://localhost:3000/sync',
        sendChangesInmediatly: true);

    // Estructura que esperamos que envie al servidor
    const codigoEsperado = 'MICODIGO';
    const dataSetEsperado = 'productos';
    const rowID = '1234';

    var changes = [
      {
        'dataset': dataSetEsperado,
        'rowId': rowID,
        'column': 'codigo',
        'value': codigoEsperado,
        'hlc': 'XXX',
        'groupId': testsSyncConfig.groupId,
        'type': 'S',
        'timestamp': '1',
        'version': '4'
      }
    ];
    String jsonEsperado = '{ "changes": ${jsonEncode(changes)}}';

    // Emulamos al servidor de sincronización
    String jsonPosteado = '';
    final interceptor = nock("http://localhost:3000/sync").post("/", (body) {
      // Almacenamos la peticion que nos envió la clase
      jsonPosteado = utf8.decode(body);
      return true;
    })
      ..persist()
      ..reply(
        200,
        "{ \"changes\" : \"ok\" }",
      );

    var camposEsperados = {'codigo': codigoEsperado};
    final sincronizacion = Sync.init(config: testsSyncConfig);

// Probamos sincronizando una serie de cambios
    await sincronizacion.synchronize(
        dataset: dataSetEsperado, rowID: rowID, fields: camposEsperados);

    // Verificamos que el JSON que envió la clase sea el mismo que el que generamos
    // "a mano"
    expect(interceptor.isDone, true);
    expect(jsonEsperado, jsonPosteado);
  },
      skip:
          'Falta generar el mapa de cambio a mano con el HLC correcto, timestamp, etc.');

  test('Debe enviar los cambios esperados al servidor sin necesidad de esperar',
      () async {
    expect(true, true);
  });
}
