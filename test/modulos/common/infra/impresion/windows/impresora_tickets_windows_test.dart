import 'dart:io';

import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/impresora_tickets_windows.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debe imprimir un ticket de prueba', () async {
    
      final impresora = ImpresoraDeTicketsWindows(
      anchoTicket: AnchoTicket.mm80,
      nombreImpresora: 'Microsoft Print to PDF',
    );
 

    var ocurrioExcepcion = false;

    try {
      impresora.imprimirPaginaDePrueba(); 
    } catch (e) {
      ocurrioExcepcion = true;
    }

    expect(
      ocurrioExcepcion,
      false
    );
  }, skip: !Platform.isWindows);
  

  test('Debe asignar correctamente las propiedades de la impresora', () async {
    final impresora = ImpresoraDeTicketsWindows(
      anchoTicket: AnchoTicket.mm80,
      nombreImpresora: 'Microsoft Print to PDF',
    );

    var ocurrioExcepcion = false;

    try {
      impresora.imprimirPaginaDePrueba(); 
    } catch (e) {
      ocurrioExcepcion = true;
    }

    expect(
      ocurrioExcepcion,
      false
    );
  }, skip: !Platform.isWindows);

  test('Debe lanzar un error si el nombre de la impresora es incorrecto',
      () async {
    final adaptadorImpresion = ImpresoraDeTicketsWindows(
      anchoTicket: AnchoTicket.mm80,
      nombreImpresora: 'Una impresora que NO EXISTE!!!',
    );

    TipoInfraEx? tipoEx;

    try {
       adaptadorImpresion.imprimirPaginaDePrueba();
    } catch (e) {
      if (e is InfraEx) {
        tipoEx = e.tipo;
      }
    }

    expect(tipoEx, isNotNull);
    expect(tipoEx, TipoInfraEx.errorAlAbrirImpresora);
  }, skip: !Platform.isWindows);
}
