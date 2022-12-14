import 'package:eleventa/modulos/common/ui/ruta.dart';
import 'package:eleventa/modulos/common/ui/widgets/barra_navegacion_inferior.dart';
import 'package:eleventa/modulos/common/ui/widgets/barra_navegacion_lateral.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

/// Scaffold con navegacion inferior que aplica solo para mobile
class ScaffoldWithBottomNavBar extends StatefulWidget {
  const ScaffoldWithBottomNavBar({Key? key, required this.child})
      : super(key: key);
  final Widget child;

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  Ruta _rutaSeleccionada = Rutas.rutas.first;

  void _onBotonSeleccionado(Ruta nuevaRuta) {
    setState(() {
      _rutaSeleccionada = nuevaRuta;
      context.go(_rutaSeleccionada.rutaURL);
    });
  }

  // int _locationToTabIndex(String location) {
  //   final index =
  //       widget.tabs.indexWhere((t) => location.startsWith(t.initialLocation));
  //   // if index not found (-1), return 0
  //   return index < 0 ? 0 : index;
  // }

  // int get _currentIndex => _locationToTabIndex(GoRouter.of(context).location);

  // void _onItemTapped(BuildContext context, int tabIndex) {
  //   // Only navigate if the tab index has changed
  //   if (tabIndex != _currentIndex) {
  //     context.go(widget.tabs[tabIndex].initialLocation);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // La navegación de toda la app esta dentro de un Scaffold

    return Scaffold(
      body: Row(children: [
        // ... si en layout desktop mostramos la barra lateral solamente
        if (context.layout.breakpoint > LayoutBreakpoint.sm) ...[
          BarraNavegacionLateral(
              rutaSeleccionada: _rutaSeleccionada,
              onBotonSeleccionado: _onBotonSeleccionado),
          const VerticalDivider(thickness: 1, width: 0),
        ],
        Expanded(child: widget.child),
      ]),
      // ... y la barra inferior solo en modo mobile
      bottomNavigationBar: context.layout.breakpoint <= LayoutBreakpoint.sm
          ? BarraNavegacionInferior(
              rutaSeleccionada: _rutaSeleccionada,
              onBotonSeleccionado: _onBotonSeleccionado,
            )
          : null,
    );
  }
}
