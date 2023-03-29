import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/texto_atajo.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class BotonAccionDeVenta extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String label;
  final String? atajoTeclado;
  final IconData icon;
  final bool enabled;
  final String hintText;
  final void Function()? onTap;

  BotonAccionDeVenta({
    required this.label,
    required this.icon,
    this.enabled = true,
    this.onTap,
    Key? key,
    this.atajoTeclado,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.p36,
      width: esDesktop.resolve(context) ? Sizes.p40 : Sizes.p24,
      child: Tooltip(
        message: hintText,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black54,
        ),
        height: 20,
        textStyle: const TextStyle(
          fontSize: 10,
          color: ColoresBase.white,
        ),
        waitDuration: const Duration(seconds: 2),
        child: Card(
          elevation: Sizes.p0,
          margin: const EdgeInsets.all(Sizes.p1_5),
          color: !enabled ? ColoresBase.primario100 : ColoresBase.primario100,
          shape: RoundedRectangleBorder(
              side: const BorderSide(
                  color: ColoresBase.primario200, width: Sizes.px),
              borderRadius: BorderRadius.circular(Sizes.p2)),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              canRequestFocus: false,
              enableFeedback: true,
              excludeFromSemantics: true,
              hoverColor:
                  enabled ? ColoresBase.primario200 : ColoresBase.primario100,
              highlightColor: ColoresBase.primario500,
              borderRadius: BorderRadius.circular(Sizes.p2),
              onTap: enabled ? onTap : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    icon,
                    color: !enabled
                        ? ColoresBase.neutral400
                        : ColoresBase.neutral500,
                    size: esDesktop.resolve(context) ? Sizes.p8 : Sizes.p4,
                  ),
                  const SizedBox(height: Sizes.p4),
                  Wrap(
                    children: [
                      if ((atajoTeclado != null) && esDesktop.resolve(context))
                        TextoAtajoTeclado(atajo: atajoTeclado!),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: esDesktop.resolve(context)
                                ? TextSizes.textXs
                                : TextSizes.textXxs,
                            color: !enabled
                                ? ColoresBase.neutral400
                                : ColoresBase.neutral600),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
