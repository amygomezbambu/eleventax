import 'dart:ffi';

import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/exception/win32_utils.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class ObtenerListadoDeImpresoras {
  static int flags = PRINTER_ENUM_LOCAL;
  static late Pointer<DWORD> pBuffSize;
  static late Pointer<DWORD> bPrinterLen;
  static late Pointer<BYTE> rawBuffer;

  static Future<List<String>> obtener() async {
    var result = <String>[];

    try {
      _getBufferSize();

      try {
        _readRawBuff();
        result = parse().toList();
      } finally {
        free(rawBuffer);
      }
    } finally {
      free(pBuffSize);
      free(bPrinterLen);
    }

    return result;
  }

  static void _getBufferSize() {
    pBuffSize = calloc<DWORD>();
    bPrinterLen = calloc<DWORD>();

    EnumPrinters(flags, nullptr, 2, nullptr, 0, pBuffSize, bPrinterLen);

    if (pBuffSize.value == 0) {
      throw InfraEx(
        message: 'Falla al asignar tamaño de buffer de impresora',
        innerException: generarExcepcionDeErrorWin32(),
        tipo: TipoInfraEx.win32Exception,
      );
    }
  }

  static void _readRawBuff() {
    rawBuffer = malloc.allocate<BYTE>(pBuffSize.value);

    final isRawBuffFail = EnumPrinters(flags, nullptr, 2, rawBuffer,
            pBuffSize.value, pBuffSize, bPrinterLen) ==
        0;

    if (isRawBuffFail) {
      throw InfraEx(
        message: 'Falla al asignar tamaño de buffer de impresora',
        innerException: 0,
        tipo: TipoInfraEx.win32Exception,
      );
    }
  }

  static Iterable<String> parse() sync* {
    for (var i = 0; i < bPrinterLen.value; i++) {
      final printer = rawBuffer.cast<PRINTER_INFO_2>().elementAt(i);
      yield printer.ref.pPrinterName.toDartString();
    }
  }
}

