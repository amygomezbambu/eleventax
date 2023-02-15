import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/l10n/generated/l10n.dart';

class BotonCobrarVenta extends StatelessWidget {
  final double totalDeVenta;
  final VoidCallback onTap;
  final bool dense;

  const BotonCobrarVenta(
      {Key? key,
      required this.totalDeVenta,
      required this.onTap,
      this.dense = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final m = L10n.of(context);

    return Container(
      margin: dense
          ? const EdgeInsets.fromLTRB(12, 10, 12, 10)
          : const EdgeInsets.fromLTRB(3, 10, 3, 10),
      height: dense ? 60 : 70,
      child: ExBoton.primario(
          label: m.ventas_boton_cobrar(totalDeVenta),
          tamanoFuente: dense ? 20 : 25,
          icon: Iconos.register,
          onTap: onTap,
          key: const ValueKey('payButton')),
    );
  }
}
