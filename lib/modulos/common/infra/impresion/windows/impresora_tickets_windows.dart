import 'dart:ffi';

import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';

import 'package:eleventa/modulos/common/exception/win32_utils.dart';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

class ImpresoraDeTicketsWindows implements IImpresoraDeTickets {
  final String _nombreImpresora;
  final AnchoTicket _anchoTicket;
  late Arena _alloc;
  static const tipoImpresion = 'XPS_PASS'; // RAW, TEXT or XPS_PASS

  ImpresoraDeTicketsWindows(
      {required String nombreImpresora, required AnchoTicket anchoTicket})
      : _nombreImpresora = nombreImpresora,
        _anchoTicket = anchoTicket;

  @override
  Future<bool> abrirCajon() {
    // TODO: implement abrirCajon

    throw UnimplementedError();
  }

  @override
  configurarImpresora(AnchoTicket anchoTicket) {
    // TODO: implement configurarImpresora
    anchoTicket = _anchoTicket;
    throw UnimplementedError();
  }

  @override
  imprimirPaginaDePrueba() {
    final data = <String>[
      for (var i = 0; i < 10; i++) 'Hello world line $i',
    ];

    _imprimirLineas(data, nombreDocumento: 'Ticket de prueba');
  }

  @override
  imprimir(List<String> lineasAImprimir) {
    _imprimirLineas(lineasAImprimir, nombreDocumento: 'Ticket de prueba');
  }

  bool _imprimirLineas(List<String> data,
      {String nombreDocumento = 'Documento'}) {
    var res = false;

    if (data.isEmpty) {
      return res;
    }

    using((Arena alloc) {
      _alloc = alloc;

      final printerHandle = _startRawPrintJob(
          nombreImpresora: _nombreImpresora,
          nombreDocumento: 'eleventa - $nombreDocumento',
          dataType: ImpresoraDeTicketsWindows.tipoImpresion);

      res = _startRawPrintPage(printerHandle);

      for (final item in data) {
        debugPrint(item);
        if (res) {
          res = _printRawData(printerHandle, '$item\n');
        }
      }
      _endRawPrintPage(printerHandle);
      _endRawPrintJob(printerHandle);
    });

    return res;
  }

  //REGION WIN32 API

  Pointer<HANDLE> _startRawPrintJob({
    required String nombreImpresora,
    required String nombreDocumento,
    required String dataType,
  }) {
    final pNombreImpresora = nombreImpresora.toNativeUtf16(allocator: _alloc);
    final phImpresora = _alloc<HANDLE>();

    // https://docs.microsoft.com/en-us/windows/win32/printdocs/openprinter
    var fSuccess = OpenPrinter(pNombreImpresora, phImpresora, nullptr);
    if (fSuccess == 0) {
      final error = GetLastError();

      throw InfraEx(
        message: 'Error en OpenPrinter: $nombreImpresora',
        innerException: generarExcepcionDeErrorWin32(error),
        tipo: TipoInfraEx.errorAlAbrirImpresora,
      );
    }

    // https://docs.microsoft.com/en-us/windows/win32/printdocs/doc-info-1
    final pDocInfo = _alloc<DOC_INFO_1>()
      ..ref.pDocName = nombreImpresora.toNativeUtf16(allocator: _alloc)
      ..ref.pDatatype =
          dataType.toNativeUtf16(allocator: _alloc) // RAW, TEXT or XPS_PASS
      ..ref.pOutputFile = nullptr;

    //https://docs.microsoft.com/en-us/windows/win32/printdocs/startdocprinter
    fSuccess = StartDocPrinter(
        phImpresora.value,
        1, // Version of the structure to which pDocInfo points.
        pDocInfo);
    if (fSuccess == 0) {
      final error = GetLastError();

      StackTrace.current;

      throw InfraEx(
        message: 'Error en StartDocPrinter: $nombreImpresora',
        innerException: generarExcepcionDeErrorWin32(error),
        tipo: TipoInfraEx.errorAlImprimir,
      );
    }

    return phImpresora;
  }

  bool _startRawPrintPage(Pointer<HANDLE> phPrinter) {
    //https://docs.microsoft.com/en-us/windows/win32/printdocs/startpageprinter
    return StartPagePrinter(phPrinter.value) != 0;
  }

  bool _endRawPrintPage(Pointer<HANDLE> phPrinter) {
    return EndPagePrinter(phPrinter.value) != 0;
  }

  bool _endRawPrintJob(Pointer<HANDLE> phPrinter) {
    return EndDocPrinter(phPrinter.value) > 0 &&
        ClosePrinter(phPrinter.value) != 0;
  }

  bool _printRawData(Pointer<HANDLE> phPrinter, String dataToPrint) {
    final cWritten = _alloc<DWORD>();
    final data = dataToPrint.toNativeUtf8(allocator: _alloc);

    // https://docs.microsoft.com/en-us/windows/win32/printdocs/writeprinter
    final result =
        WritePrinter(phPrinter.value, data, dataToPrint.length, cWritten);

    if (dataToPrint.length != cWritten.value) {
      final error = GetLastError();

      throw InfraEx(
        message: 'Error en WritePrinter',
        innerException: generarExcepcionDeErrorWin32(error),
        tipo: TipoInfraEx.errorAlImprimir,
      );
    }

    return result != 0;
  }

  //ENDREGION
}
