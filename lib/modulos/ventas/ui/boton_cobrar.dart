import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    var m = AppLocalizations.of(context)!;

    return Container(
      margin: dense
          ? const EdgeInsets.fromLTRB(12, 10, 12, 10)
          : const EdgeInsets.fromLTRB(3, 10, 3, 10),
      height: dense ? 60 : 70,
      child: ExBotonPrimario(
          label: 'Cobrar ${m.moneda(totalDeVenta)}',
          tamanoFuente: dense ? 20 : 25,
          icon: Iconos.register,
          onTap: () => {debugPrint('hello')},
          key: const ValueKey('payButton')),
    );
  }
}
