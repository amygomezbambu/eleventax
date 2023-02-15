import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/texto_atajo.dart';
import 'package:flutter/material.dart';

class BotonAccionDeVenta extends StatelessWidget {
  final String label;
  final String? atajoTeclado;
  final IconData icon;
  final bool enabled;
  final String hintText;
  final void Function()? onTap;

  const BotonAccionDeVenta({
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
    return Expanded(
      child: SizedBox(
        height: Sizes.p36,
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
                      size: Sizes.p8,
                    ),
                    const SizedBox(height: Sizes.p4),
                    Wrap(
                      children: [
                        if (atajoTeclado != null)
                          TextoAtajoTeclado(atajo: atajoTeclado!),
                        const SizedBox(
                          width: 4,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: TextSizes.textXs,
                                color: !enabled
                                    ? ColoresBase.neutral400
                                    : ColoresBase.neutral600),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
