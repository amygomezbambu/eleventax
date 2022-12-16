import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:eleventa/modulos/common/ui/tema/dimensiones.dart';
import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.only(top: Sizes.p1, bottom: Sizes.p4),
        icon: Icon(
          ruta.icon,
          semanticLabel: ruta.nombre,
        ),
        selectedIcon: Icon(ruta.icon),
        label: Text(ruta.nombre),
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
      minWidth: Sizes.p16,
      backgroundColor: ColoresBase.primario900,
      indicatorColor: ColoresBase.neutral600,
      useIndicator: true,
      leading: Padding(
        padding: const EdgeInsets.only(top: Sizes.p8),
        child: Column(
          children: [
            const EleventaLogo(),
            Container(
              width: Sizes.p12,
              padding: const EdgeInsets.only(top: Sizes.p5, bottom: Sizes.p1),
              child: const Divider(
                  height: Sizes.p0,
                  color: ColoresBase.primario800,
                  thickness: Sizes.p0),
            ),
          ],
        ),
      ),
      extended: false,
      elevation: Sizes.p2_0,
      unselectedIconTheme:
          const IconThemeData(color: ColoresBase.neutral500, size: Sizes.p5),
      selectedIconTheme:
          const IconThemeData(color: ColoresBase.white, size: Sizes.p5),
      destinations: [
        ...construirNavegacion(context),
      ],
    );
  }
}
