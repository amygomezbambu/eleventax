// ignore: file_names

enum TipoAlineacion {
  izquierda('\x1B\x61\x00'),
  centro('\x1B\x61\x01'),
  derecha('\x1B\x61\x02'),
  ;

  final String comando;
  const TipoAlineacion(this.comando);
}

enum TipoFormatoFuente {
  normal('\x1B\x45\x00'),
  negrita('\x1B\x45\x01'),
  subrayado('\x1B\x2D\x01'),
  negritaSubrayado('\x1B\x45\x01\x1B\x2D\x01'),
  ;

  final String comando;
  const TipoFormatoFuente(this.comando);
}

enum TipoTamanioFuente {
  normal('\x1B\x21\x00'),
  grande('\x1B\x21\x11'),
  ;

  final String comando;
  const TipoTamanioFuente(this.comando);
}

enum TipoComandoImpresora {
  abrirCajon('\x1B\x70\x00\xFF\xFF'),
  cortarPapelFull('\x1B\x64\x02'),
  cortarPapelParcial('\x1B\x64\x01'),
  ;

  final String comando;
  const TipoComandoImpresora(this.comando);
}

class ComandosEscPos {
  static const String inicializarImpresora =
      '\x1B\x40'; // Inicializar impresora
  static const String abrirCajon = '\x1B\x70\x00\xFF\xFF'; // Abrir cajon

  static const String cortarPapelFull = '\x1B\x64\x02'; // Cortar papel full
  static const String cortarPapelParcial =
      '\x1B\x64\x01'; // Cortar papel parcial
  static const String avanzarPapel = '\x1B\x4A\xFF'; // Avanzar papel
  static const String avanzarPapel5Lineas = '\x1B\x4A\x05'; // Avanzar papel N lineas

  static const String alineacionIzquierda =
      '\x1B\x61\x00'; // Alineacion izquierda
  static const String alineacionCentro = '\x1B\x61\x01'; // Alineacion centro
  static const String alineacionDerecha = '\x1B\x61\x02'; // Alineacion derecha

  static const String tamanioFuenteNormal =
      '\x1B\x21\x00'; // Tamaño fuente normal
  static const String tamanioFuenteGrande =
      '\x1B\x21\x11'; // Tamaño fuente grande

  static const String negritaOn = '\x1B\x45\x01'; // Negrita ON
  static const String negritaOff = '\x1B\x45\x00'; // Negrita OFF
  static const String subrayadoOn = '\x1B\x2D\x01'; // Subrayado ON
  static const String subrayadoOff = '\x1B\x2D\x00'; // Subrayado OFF

  static const String esc = '\x1B'; // esc command
  static const String gs = '\x1D'; // GS command
  static const String fs = '\x1C'; // FS command

  static const String openCashDrawer1 = "${esc}p\x00\x0F\x96";
  static const String openCashDrawer = '\x1b\x70\x00';

  static const String boldOn = "${esc}E\x01"; // Bold font ON
  static const String boldOff = "${esc}E\x00"; // Bold font OFF
  static const String doubleOn =
      "$gs!\x11"; // 2x sized text (double-high + double-wide)
  static const String doubleOff = "$gs!\x00"; // Normal text
  static const String underlineOn = "$esc-\x01"; // Underline font 1-dot ON
  static const String underlineOff = "$esc-\x00"; // Underline font 1-dot OFF
  static const String reverseOn = "${gs}B\x01"; // Reverse color ON
  static const String reverseOff = "${gs}B\x00"; // Reverse color OFF
  static const String upsideDownOn = "$esc{\x01"; // Upside down ON
  static const String upsideDownOff = "$esc{\x00"; // Upside down OFF
  static const String smallOn = "${esc}M\x01"; // Small font ON
  static const String smallOff = "${esc}M\x00"; // Small font OFF
  static const String fontA = "${esc}M\x00"; // Font type A
  static const String fontB = "${esc}M\x01"; // Font type B
  static const String fontC = "${esc}M\x02"; // Font type C

  static const String fontSize1 = "$gs!\x00"; // Font size 1
  static const String fontSize2 = "$gs!\x01"; // Font size 2
  static const String fontSize3 = "$gs!\x02"; // Font size 3
  static const String fontSize4 = "$gs!\x03"; // Font size 4
  static const String fontSize5 = "$gs!\x04"; // Font size 5
  static const String fontSize6 = "$gs!\x05"; // Font size 6
  static const String fontSize7 = "$gs!\x06"; // Font size 7
  static const String fontSize8 = "$gs!\x07"; // Font size 8
  static const String fontSize9 = "$gs!\x08"; // Font size 9
  static const String fontSize10 = "$gs!\x09"; // Font size 10

  static const String alignLeftOn = "${esc}a\x00"; // Left justification ON
  static const String alignLeftOff = "${esc}a\x30"; // Left justification OFF
  static const String alignCenterOn = "${esc}a\x01"; // Centering
  static const String alignCenterOff = "${esc}a\x31"; // Centering OFF
  static const String alignRightOn = "${esc}a\x02"; // Right justification
  static const String alignRightOff = "${esc}a\x32"; // Right justification OFF

  static const String saltoLinea = "\n"; // Salto de linea
  static const String tabulador = "\t"; // Tabulador
  static const String espacio = " "; // Espacio
  static const String retornoCarro = "\r"; // Retorno de carro
  static const String saltoPagina = "\f"; // Salto de pagina
  static const String beep = "\x07"; // Beep
  static const String beep2 = "\x1B\x42\x0F\x0F\x32"; // Beep
  static const String saltoRetornoCarro = "\r\n"; // Salto de linea y retorno de carro

  static const String codigoBarras = "\x1D\x6B\x02"; // Codigo de barras

 
}
