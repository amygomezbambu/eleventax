//import 'package:eleventa/modules/common/ui/ui_consts.dart' as ui;
import 'package:eleventa/modulos/common/ui/rutas.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/common/ui/layout_desktop.dart';
import 'package:eleventa/modulos/common/ui/layout_mobile.dart';

class LayoutPrincipal extends StatefulWidget {
  final Widget child;

  const LayoutPrincipal({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  LayoutPrincipalState createState() => LayoutPrincipalState();
}

class LayoutPrincipalState extends State<LayoutPrincipal> {
  int index = 0;

  void onIndexSelect(newIndex) {
    setState(() {
      index = newIndex;

      // TODO: Refactorizar para no depender del indice
      switch (index) {
        case 0:
          context.goNamed(Rutas.ventas.name);
          break;
        case 1:
          context.goNamed(Rutas.productos.name);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
            color: Colors.white70,
            iconSize: 30,
            icon: const Icon(Icons.chevron_left),
            onPressed: () {}),
        title: Text('eleventa', // ToDO: Incluir el nombre del módulo
            style: TextStyle(
                color: Colors.white,
                fontSize: (context.layout.breakpoint <= LayoutBreakpoint.sm)
                    ? 19
                    : 12)),
        toolbarHeight:
            (context.layout.breakpoint <= LayoutBreakpoint.sm) ? 55 : 38,
        backgroundColor: DesignSystem.titleColor,
        elevation: 1,
        surfaceTintColor: null,
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            focusColor: Colors.white,
            icon: const Icon(
              Icons.feedback,
              color: Colors.white38,
            ),
            //tooltip: 'Dar retroalimentación',
            onPressed: () {
              // TODO: Mostrar vista para mandar feedback a desarrolladores
            },
          )
        ],
      ),
      body: Row(
        children: [
          if (context.layout.breakpoint > LayoutBreakpoint.sm) ...[
            BarraNavegacionLateral(
                selectedIndex: index, onIndexSelect: onIndexSelect),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          Expanded(child: widget.child),
          Container(
            color: Colors.amber,
            height: 30,
          )
        ],
      ),
      bottomNavigationBar: context.layout.breakpoint <= LayoutBreakpoint.sm
          ? BarraNavegacionInferior(
              selectedIndex: index,
              onIndexSelect: onIndexSelect,
            )
          : null,
    );
  }
}
