//import 'package:eleventa/modules/common/ui/ui_consts.dart' as ui;
import 'package:eleventa/modulos/common/ui/navegacion_md.dart';
import 'package:eleventa/modulos/common/ui/navegacion_sm.dart';
import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';

import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int index = 0;

  void onIndexSelect(newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
            (context.layout.breakpoint > LayoutBreakpoint.sm)
                ? 'eleventa punto de venta'
                : 'Ventas', // ToDO: Incluir el nombre del módulo
            style: TextStyle(
                color: Colors.white,
                fontSize: (context.layout.breakpoint > LayoutBreakpoint.sm)
                    ? 12
                    : 16)),
        toolbarHeight:
            (context.layout.breakpoint > LayoutBreakpoint.sm) ? 38 : 55,
        backgroundColor: DesignSystem.titleColor,
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.feedback),
            tooltip: 'Dar retroalimentación',
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
          const Expanded(
              key: ValueKey('HomePageBody'),
              child: VistaVentas(
                titulo: 'Ventas',
              )),
        ],
      ),
      bottomNavigationBar: context.layout.breakpoint < LayoutBreakpoint.sm
          ? BarraNavegacionInferior(
              selectedIndex: index,
              onIndexSelect: onIndexSelect,
            )
          : null,
    );
  }
}
