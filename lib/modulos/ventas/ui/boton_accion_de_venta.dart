import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

class BotonAccionDeVenta extends StatelessWidget {
  final String _label;
  final IconData _icon;

  const BotonAccionDeVenta(
    this._label,
    this._icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: Sizes.p36,
        child: Card(
          elevation: Sizes.p0,
          margin: const EdgeInsets.all(Sizes.p1_5),
          color: ColoresBase.primario100,
          shape: RoundedRectangleBorder(
              side: const BorderSide(
                  color: ColoresBase.primario100, width: Sizes.px),
              borderRadius: BorderRadius.circular(Sizes.p2)),
          child: InkWell(
            hoverColor: ColoresBase.primario200,
            highlightColor: ColoresBase.primario300,
            borderRadius: BorderRadius.circular(Sizes.p2),
            onTap: () => {debugPrint('Se hizo clic en accion')},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _icon,
                  color: ColoresBase.neutral500,
                  size: Sizes.p8,
                ),
                const SizedBox(height: Sizes.p2),
                Text(
                  _label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: TextSizes.textXs,
                      color: ColoresBase.neutral600),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
