

import 'package:eleventa/modulos/common/utils/regex_emoji.dart';

class StringUtils {
  bool isDigit(String s, int index) => (s.codeUnitAt(index) ^ 0x30) <= 9;

  String limpiarCaracteresInvisibles(String input, [String sustituto = '']) {
    var resultado = '';
    var encontrado = false;

    for (var caracter in input.split('')) {
      encontrado = false;

      encontrado = _buscarEnListadoDeCodigos(caracter)
          ? true
          : _buscarEnCodigosASCII(caracter);

      if (encontrado) {
        resultado += sustituto;
      } else {
        resultado += caracter;
      }
    }

    return resultado;
  }

  String removerEmojis(String texto) {
    return texto.replaceAll(RegExp(regexEmoji), '');
  }

  String removerExcesoDeEspacios(String input) {
    return input.trim().replaceAll(RegExp(' +'), ' ');
  }

  ///
  String removerEspacios(String input) {
    return input.replaceAll(RegExp(r's+'), '');
  }

  String capitalizar(String input) {
    if (input.isEmpty) {
      return '';
    }

    var palabras = input.trim().toLowerCase().split(' ');
    for (var i = 0; i < palabras.length; i++) {
      if (palabras[i].length > 1 || i == 0) {
        palabras[i] = palabras[i].substring(0, 1).toUpperCase() +
            palabras[i].substring(1);
      }
    }

    return palabras.join(' ');
  }

  /* #region metodos auxiliares */
  bool _buscarEnListadoDeCodigos(String caracter) {
    // La lista de códigos hexadecimales de espacios
    // en blanco invisibles la tomamos de:
    // https://gist.github.com/JamoCA/42c3be286185aff0476d5888f0a819ff
    List<int> codigoHexadecimal = [
      0x00A0,
      0x0085,
      0x00A0,
      0x1680,
      0x180E,
      0x2000,
      0x2001,
      0x2002,
      0x2003,
      0x2004,
      0x2005,
      0x2006,
      0x2007,
      0x2008,
      0x2009,
      0x200A,
      0x200B,
      0x200C,
      0x200D,
      0x200E,
      0x200F,
      0x2060,
      0x2028,
      0x2029,
      0x202F,
      0x205F,
      0x2420,
      0x2422,
      0x2423,
      0x2800,
      0x3000,
      0xFEFF,
      0xFF10,
      0x007F,
      0x0001,
      0x0002,
      0x0003,
      0x0004,
      0x0005,
      0x0006,
      0x0007,
      0x0008,
      0x0009,
      0x000A,
      0x000B,
      0x000C,
      0x000D,
      0x000E,
      0x000F,
      0x0010,
      0x0011,
      0x0012,
      0x0013,
      0x0014,
      0x0015,
      0x0016,
      0x0017,
      0x0018,
      0x0019,
      0x001A,
      0x001B,
      0x001C,
      0x001D,
      0x001E,
      0x001F,
    ];

    var encontrado = false;

    for (var codigo in codigoHexadecimal) {
      if (codigo == caracter.codeUnitAt(0)) {
        encontrado = true;
        break;
      }
    }

    return encontrado;
  }

  bool _buscarEnCodigosASCII(String caracter) {
    var encontrado = false;

    for (var i = 0; i < 32; i++) {
      if (i == caracter.codeUnitAt(0)) {
        encontrado = true;
        break;
      }
    }

    return encontrado;
  }
  /* #endregion */
}
