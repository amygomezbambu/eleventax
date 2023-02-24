import 'package:flutter/material.dart';

/// Colores usados en la aplicación para mantener un estilo consistente
class Colores {
  static const Color accionPrimaria = ColoresBase.primario600;
  static const Color acento = ColoresBase.primario300;
  static const Color textoNormal = ColoresBase.neutral800;

  static const Color navegacionBackground = ColoresBase.primario900;

  static const campoFondo = ColoresBase.neutral200;
  static const campoIcono = ColoresBase.neutral400;
  static const campoTextoHint = Colors.black;
  static const campoTextoValor = Colors.black;
  static const campoBordeEnfocado = ColoresBase.primario600;
}

/// Paleta de colores estandard usado en la aplicación
/// de acuerdo al Design System de eleventa
class ColoresBase {
  static const Color shadow100 = Color.fromARGB(45, 24, 40, 13);

  static const Color primario50 = Color(0xfff2f6fc);
  static const Color primario100 = Color(0xffe1ebf8);
  static const Color primario200 = Color(0xffCFDDF0);
  static const Color primario300 = Color(0xffADC6E7);
  static const Color primario400 =
      Color.fromARGB(255, 137, 196, 251); //Color(0xff82A5EA);
  static const Color primario500 = Color(0xFF459BF1); //Color(0xff698BCE);
  static const Color primario600 = Color(0xff4a73c7);
  static const Color primario700 = Color(0xff3C5EA3);
  static const Color primario800 = Color(0xff34435A);
  static const Color primario900 = Color(0xff212936);

  // Blue Gray
  static const Color neutral50 = Color(0xfff8fafc);
  static const Color neutral100 = Color(0xfff1f5f9);
  static const Color neutral200 = Color(0xffe2e8f0);
  static const Color neutral300 = Color(0xffcbd5e1);
  static const Color neutral400 = Color(0xff94a3b8);
  static const Color neutral500 = Color(0xff64748b);
  static const Color neutral600 = Color(0xff475569);
  static const Color neutral700 = Color(0xff334155);
  static const Color neutral800 = Color(0xff1e293b);
  static const Color neutral900 = Color(0xff0f172a);

  static const Color red300 = Color(0xffAB091E);
  static const Color yellow900 = Color(0xffBA2525);
  static const Color yellow100 = Color(0xfffacdcd);

  static const Color white = Colors.white;
}
