import 'dart:io';

import 'package:eleventa/modulos/common/infra/impresion/windows/adaptador_impresion_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  test('Debe obtener el listado de las impresoras instaladas', () async {
    var adaptadorImpresion = AdaptadorImpresionWindows();

    var listadoImpresoras =
        await adaptadorImpresion.obtenerImpresorasDisponibles();

    expect(
      listadoImpresoras.length,
      greaterThan(0),
    );
  }, skip: !Platform.isWindows);
}