import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class OpcionConfigurable extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String? label;
  final String? textoAyuda;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  OpcionConfigurable({
    super.key,
    this.label,
    required this.child,
    this.textoAyuda,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: Sizes.p20,
      ),
      width: double.infinity,
      padding: padding ??
          EdgeInsets.only(
            top: esDesktop.resolve(context)
                ? Sizes.p0
                : label != null
                    ? Sizes.p5
                    : Sizes.p0,
          ),
      margin: const EdgeInsets.all(0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
        ),
      ),
      child:
          // Un Flex actua con Column o Row dependiendo de "direction"
          Flex(
              direction:
                  esDesktop.resolve(context) ? Axis.horizontal : Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: esDesktop.resolve(context)
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
            SizedBox(
              width: esDesktop.resolve(context) ? Sizes.p64 : null,
              height: !esDesktop.resolve(context) ? Sizes.p6 : null,
              child: Wrap(
                children: [
                  label != null
                      ? Text(
                          label!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const SizedBox(),
                  (textoAyuda != null) && (esDesktop.resolve(context))
                      ? Padding(
                          padding: const EdgeInsets.only(left: Sizes.p2),
                          child: Tooltip(
                            message: textoAyuda,
                            child: const Icon(
                              Icons.help,
                              size: 18,
                              color: ColoresBase.neutral500,
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            Container(
              child: child,
            ),
          ]),
    );
  }
}
