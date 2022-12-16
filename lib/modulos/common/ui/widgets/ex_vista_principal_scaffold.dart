import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';

/// Scaffold que se encarga de mostrar un [[AppBar]] solamente
/// cuando estamos en vistas responsivas mobile, en caso contrario
/// muestra un simple titulo en texto
class VistaPrincipalScaffold extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String titulo;
  final Widget child;
  final List<Widget>? actions;

  VistaPrincipalScaffold({
    Key? key,
    required this.titulo,
    required this.child,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: (context.layout.breakpoint <= LayoutBreakpoint.sm)
            ? ExAppBar(
                title: Padding(
                  padding: const EdgeInsets.only(top: Sizes.p3),
                  child: Text(titulo,
                      style: const TextStyle(
                          color: Colors.white, fontSize: TextSizes.textLg)),
                ),
                actions: actions)
            : null,
        body: child);
  }
}
