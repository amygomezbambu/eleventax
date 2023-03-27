import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

/// Cascaron de una vista detalle, el parámetro [factorAnchoDesktop] define
/// el ancho del detalle en desktop, por defecto es 1.0, pero en la VistaMaestroDetalle
/// se usa 0.7 para que el detalle ocupe el 70% del ancho de la pantalla
class VistaDetalle extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String? titulo;
  final Widget child;
  final double factorAnchoDesktop;

  VistaDetalle({
    super.key,
    required this.child,
    this.titulo,
    this.factorAnchoDesktop = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final paddingContenedor = esDesktop.resolve(context) ? Sizes.p10 : Sizes.p4;

    return Container(
        color: ColoresBase.neutral50,
        // En desktop el alto es todo el disponible
        height: esDesktop.resolve(context) ? double.infinity : null,
        // en mobile el ancho es todo el disponible
        width: !esDesktop.resolve(context) ? double.infinity : null,
        child: FractionallySizedBox(
          widthFactor: esDesktop.resolve(context) ? factorAnchoDesktop : 1,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Margin(
                margin: EdgeInsets.only(
                  left: paddingContenedor,
                  right: paddingContenedor,
                ),
                child: child,
              )
            ]),
          ),
        ));
  }
}
