import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

class TextoAtajoTeclado extends StatelessWidget {
  final String atajo;
  const TextoAtajoTeclado({Key? key, required this.atajo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      atajo,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: (atajo.length == 1) ? TextSizes.textXs : TextSizes.textXs,
        color: ColoresBase.neutral400,
      ),
    );
  }
}
