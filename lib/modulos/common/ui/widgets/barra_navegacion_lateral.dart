import 'package:flutter/material.dart';

import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/common/ui/ruta.dart';
import 'package:eleventa/modulos/common/ui/widgets/eleventa_logo.dart';

class BarraNavegacionLateral extends StatelessWidget {
  final Ruta rutaSeleccionada;
  final Function(Ruta) onBotonSeleccionado;

  void _manejarIndiceSeleccionado(int indice) {
    Ruta rutaSeleccionada =
        Rutas.rutas.firstWhere((e) => Rutas.rutas.indexOf(e) == indice);
    onBotonSeleccionado(rutaSeleccionada);
  }

  const BarraNavegacionLateral({
    Key? key,
    required this.rutaSeleccionada,
    required this.onBotonSeleccionado,
  }) : super(key: key);

  List<NavigationRailDestination> construirNavegacion(BuildContext context) {
    List<NavigationRailDestination> navegacion = [];

    for (var ruta in Rutas.rutas) {
      var destination = NavigationRailDestination(
        padding: const EdgeInsets.only(top: 5, bottom: 15),
        icon: Icon(
          ruta.icon,
          semanticLabel: ruta.nombre,
        ),
        selectedIcon: Icon(ruta.icon),
        label: const Text('Ventas'),
      );

      navegacion.add(destination);
    }

    return navegacion;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: Rutas.rutas.indexOf(rutaSeleccionada),
      onDestinationSelected: _manejarIndiceSeleccionado,
      labelType: NavigationRailLabelType.none,
      minWidth: 65,
      backgroundColor: DesignSystem.backgroundColor,
      indicatorColor: const Color(0xFF1d415f),
      useIndicator: true,
      leading: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Column(
          children: [
            const EleventaLogo(),
            Container(
              width: 50,
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child:
                  Divider(height: 1, color: Colors.blueGrey[800], thickness: 1),
            ),
          ],
        ),
      ),
      extended: false,
      //minExtendedWidth: 170,
      unselectedIconTheme: const IconThemeData(
          color: Color.fromARGB(255, 219, 219, 219), size: 20),
      selectedIconTheme: const IconThemeData(color: Colors.white, size: 20),
      selectedLabelTextStyle: const TextStyle(
          color: Colors.white, fontFamily: 'Inter', fontSize: 12),
      unselectedLabelTextStyle: const TextStyle(
          color: Color.fromARGB(255, 197, 196, 196),
          fontFamily: 'Inter',
          fontSize: 13),
      destinations: [
        ...construirNavegacion(context),
      ],
    );
  }
}
