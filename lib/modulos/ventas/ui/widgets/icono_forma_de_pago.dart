import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';

class IconoFormaDePago extends StatelessWidget {
  final TipoFormaDePago tipoFormaDePago;
  final Color color;

  const IconoFormaDePago({
    Key? key,
    required this.tipoFormaDePago,
    this.color = ColoresBase.neutral500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icono;
    switch (tipoFormaDePago) {
      case TipoFormaDePago.efectivo:
        icono = Icons.attach_money;
        break;
      default:
        icono = Icons.credit_card;
        break;
    }

    return Icon(
      icono,
      color: color,
    );
  }
}
