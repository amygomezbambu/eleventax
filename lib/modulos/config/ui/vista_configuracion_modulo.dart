import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class VistaConfiguracionModulo extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String? titulo;
  final Widget child;

  VistaConfiguracionModulo({
    super.key,
    required this.child,
    this.titulo,
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
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisSize: MainAxisSize.max,
              children: [
                titulo != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                          top: Sizes.p10,
                          left: Sizes.p10,
                          right: Sizes.p10,
                        ),
                        child: Text(
                          titulo!,
                          style: const TextStyle(
                              fontSize: TextSizes.text2xl,
                              color: ColoresBase.neutral700,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: EdgeInsets.only(
                      left: paddingContenedor, right: paddingContenedor),
                  child: child,
                )
              ]),
        ));
  }
}
