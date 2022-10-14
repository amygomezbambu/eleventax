import 'package:flutter/material.dart';

// Constantes de valores de nuestro Design System

const Color primary800 = Color(0xFF273B52);

const Color neutral800 = Color(0xFF222833);
const Color neutral700 = Color(0xFF616A79);
const Color neutral600 = Color(0xFF8A94A5);
const Color neutral500 = Color(0xFFB9C3CD);
const Color neutral400 = Color(0xFFCFD5DD);
const Color neutral300 = Color(0xFFE1E6EB);
const Color neutral200 = Color(0xFFF7F8FA);

class DesignSystem {
  static const double defaultFontSize = 16;
  // Colores
  static const Color backgroundColor = Color.fromARGB(255, 22, 29, 39);
  static const Color titleColor = Color(0xFF1F2937);
  static const Color accionPrimaria = Color(0xFF459BF1);

  /// Espaciado relativo entre elementos responsivo
  static double padding(context) {
    return context.layout
        .value(xs: 0.0, sm: 12.0, md: 24.0, lg: 32.0, xl: 48.0);
    ;
  }
}
