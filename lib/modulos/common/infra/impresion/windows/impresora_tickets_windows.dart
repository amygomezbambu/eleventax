import 'dart:ffi';

import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/comandos_esc_pos.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/exception/win32_utils.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class ImpresoraDeTicketsWindows implements IImpresoraDeTickets {
  final String _nombreImpresora;
  final AnchoTicket _anchoTicket;
  final List<String> _lineasAImprimir = [];
  late Arena _alloc;

  static const tipoImpresion = 'RAW'; // RAW, TEXT or XPS_PASS

  ImpresoraDeTicketsWindows(
      {required String nombreImpresora, required AnchoTicket anchoTicket})
      : _nombreImpresora = nombreImpresora,
        _anchoTicket = anchoTicket;

  @override
  Future<bool> abrirCajon() async {
    // TODO: implement abrirCajon
    return Future.value(true);
  }

  @override
  configurarImpresora(AnchoTicket anchoTicket) {
    // TODO: implement configurarImpresora
    anchoTicket = _anchoTicket;
  }

  @override
  imprimirPaginaDePrueba() {
    _inicializarImpresora();

    final data = <String>[
      for (var i = 0; i < 10; i++) 'Hello world line $i',
    ];

    _imprimirLineas(data, nombreDocumento: 'Ticket de prueba');
  }

  @override
  imprimir() async {
    if (_lineasAImprimir.isEmpty) {
      throw InfraEx(
        message: 'No hay lineas para imprimir',
        innerException: 0,
        tipo: TipoInfraEx.errorAlImprimir,
      );
    }

    _inicializarImpresora();

    if (await abrirCajon()) {
      agregarLinea(ComandosEscPos.abrirCajon);
    }

    _imprimirLineas(_lineasAImprimir, nombreDocumento: 'Ticket de prueba');
  }

  @override
  void agregarDivisor([String divisor = '=']) {
    String auxDivisor = '';
    for (int i = 0; i < appConfig.columnasTicket; i++) {
      auxDivisor += divisor;
    }

    agregarLinea(auxDivisor);
  }

  @override
  void agregarEspaciadoFinal() {
    for (int i = 0; i < appConfig.lineasEspaciado; i++) {
      agregarLineaEnBlanco();
    }
  }

  @override
  void agregarLinea(String linea,
      [TipoAlineacion alineacion = TipoAlineacion.izquierda,
      TipoTamanioFuente tamanioFuente = TipoTamanioFuente.normal]) {
    _lineasAImprimir.add(alineacion.comando + tamanioFuente.comando + linea);
  }

  @override
  void agregarLineaEnBlanco() {
    agregarLinea(ComandosEscPos.saltoRetornoCarro);
  }

  @override
  void agregarLineaJustificada(String campo, String valor,
      [TipoTamanioFuente tamanioFuente = TipoTamanioFuente.normal]) {
    agregarLinea(_impresionCampoValor(campo, valor, separador: ' '),
        TipoAlineacion.izquierda, tamanioFuente);
  }

  void _inicializarImpresora() {
    _lineasAImprimir.insert(0, ComandosEscPos.inicializarImpresora);
  }

  String _impresionCampoValor(String campo, String valor,
      {String separador = ' '}) {
    var res = campo + valor;
    var espacios = separador;
    while (res.length < appConfig.columnasTicket) {
      res = campo + espacios + valor;
      espacios += separador;
    }
    return res;
  }

  String _removerCaracteresNoImprimibles(String texto) {
    var resultado = Utils.string.removerEmojis(texto);
    //resultado = Utils.string.limpiarCaracteresInvisibles(resultado);
    resultado = Utils.string.removerAcentos(resultado);
    return resultado;
  }

  /// **********************************************************************

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
        if (res) {
          res = _printRawData(
            printerHandle,
            '${_removerCaracteresNoImprimibles(item)}\n',
          );
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
