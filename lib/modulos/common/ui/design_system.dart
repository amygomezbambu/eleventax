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
  }
}

class Colores {
  static const Color backgroundColor = Color.fromARGB(255, 22, 29, 39);
  static const Color titleColor = Color(0xFF1F2937);
  static const Color accionPrimaria = Color(0xFF459BF1);
}

/// Tamaños constantes para espaciados en la app (paddings, gaps, rounded corners etc.)
class Sizes {
  static const p4 = 4.0;
  static const p8 = 8.0;
  static const p12 = 12.0;
  static const p16 = 16.0;
  static const p20 = 20.0;
  static const p24 = 24.0;
  static const p32 = 32.0;
  static const p48 = 48.0;
  static const p64 = 64.0;
}

/// Anchos fijos para espaciados
const gapW4 = SizedBox(width: Sizes.p4);
const gapW8 = SizedBox(width: Sizes.p8);
const gapW12 = SizedBox(width: Sizes.p12);
const gapW16 = SizedBox(width: Sizes.p16);
const gapW20 = SizedBox(width: Sizes.p20);
const gapW24 = SizedBox(width: Sizes.p24);
const gapW32 = SizedBox(width: Sizes.p32);
const gapW48 = SizedBox(width: Sizes.p48);
const gapW64 = SizedBox(width: Sizes.p64);

/// Altos fijos para espaciados
const gapH4 = SizedBox(height: Sizes.p4);
const gapH8 = SizedBox(height: Sizes.p8);
const gapH12 = SizedBox(height: Sizes.p12);
const gapH16 = SizedBox(height: Sizes.p16);
const gapH20 = SizedBox(height: Sizes.p20);
const gapH24 = SizedBox(height: Sizes.p24);
const gapH32 = SizedBox(height: Sizes.p32);
const gapH48 = SizedBox(height: Sizes.p48);
const gapH64 = SizedBox(height: Sizes.p64);
