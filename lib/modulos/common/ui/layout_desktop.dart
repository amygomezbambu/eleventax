import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/common/ui/widgets/eleventa_logo.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/modulos/common/ui/rutas.dart';

class BarraNavegacionLateral extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexSelect;

  const BarraNavegacionLateral({
    Key? key,
    required this.selectedIndex,
    required this.onIndexSelect,
  }) : super(key: key);

  List<NavigationRailDestination> construirNavegacion(BuildContext context) {
    List<NavigationRailDestination> navegacion = [];

    for (var ruta in Rutas.values) {
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
      selectedIndex: selectedIndex,
      onDestinationSelected: onIndexSelect,
      labelType: NavigationRailLabelType.none,
      minWidth: 59,
      backgroundColor: DesignSystem.backgroundColor,
      indicatorColor: const Color(0xFF1d415f),
      useIndicator: true,
      leading: Padding(
        padding: const EdgeInsets.only(top: 10),
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
