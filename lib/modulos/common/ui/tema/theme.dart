import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

export 'dimensiones.dart';
export 'colores.dart';

class DesignSystem {
  static const double campoTamanoIcono = Sizes.p4;
  static const double campoTamanoTexto = TextSizes.textSm; //Sizes.p3
  static const double tamanoRoundedCorners = Sizes.p2_5;

  static BoxDecoration separadorSuperior = const BoxDecoration(
    border: Border(
      top: BorderSide(
        width: 1,
        color: ColoresBase.neutral200,
      ),
    ),
  );

  static BoxDecoration separadorInferior = const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        width: 1,
        color: ColoresBase.neutral200,
      ),
    ),
  );
}
