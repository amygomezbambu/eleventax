//import 'package:eleventa/modules/common/ui/ui_consts.dart' as ui;
import 'package:eleventa/modulos/common/ui/layout_desktop.dart';
import 'package:eleventa/modulos/common/ui/layout_mobile.dart';
import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/config/flags.dart';
import 'package:eleventa/modulos/productos/ui/vista_productos.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';

import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class LayoutPrincipal extends StatefulWidget {
  const LayoutPrincipal({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  LayoutPrincipalState createState() => LayoutPrincipalState();
}

class LayoutPrincipalState extends State<LayoutPrincipal> {
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
        leading: IconButton(
            color: Colors.white70,
            iconSize: 30,
            icon: const Icon(Icons.chevron_left),
            onPressed: () {}),
        title: Text(
            (context.layout.breakpoint <= LayoutBreakpoint.sm)
                ? 'Nuevo Producto'
                : Feature.productos.estaHabilitado()
                    ? 'productos'
                    : 'no ', // ToDO: Incluir el nombre del módulo
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
              color: Colors.white,
            ),
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
          Expanded(
              child: Feature.productos.estaHabilitado()
                  ? const VistaProductos(
                      key: ValueKey('VistaProductos'),
                      titulo: 'Productos',
                    )
                  : const VistaVentas(
                      key: ValueKey('VistaVentas'),
                      titulo: 'Ventas',
                    )),
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
