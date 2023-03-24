import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

class TextoValor extends StatelessWidget {
  final String campo;
  final String valor;
  final TextAlign align;
  final double tamanoFuente;

  const TextoValor(this.campo, this.valor,
      {super.key,
      this.align = TextAlign.right,
      this.tamanoFuente = TextSizes.textSm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            child: Text(
              campo,
              textAlign: align,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: tamanoFuente,
              ),
            ),
          ),
          Expanded(
            child: Text(valor,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: tamanoFuente,
                )),
          )
        ],
      ),
    );
  }
}
