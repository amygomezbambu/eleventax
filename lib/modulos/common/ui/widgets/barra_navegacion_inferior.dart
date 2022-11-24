import 'package:flutter/material.dart';

import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/common/ui/ruta.dart';

class BarraNavegacionInferior extends StatelessWidget {
  final Ruta rutaSeleccionada;
  final Function(Ruta) onBotonSeleccionado;

  const BarraNavegacionInferior({
    Key? key,
    required this.rutaSeleccionada,
    required this.onBotonSeleccionado,
  }) : super(key: key);

  void _manejarIndiceSeleccionado(int indice) {
    Ruta rutaSeleccionada = Ruta.values.firstWhere((e) => e.index == indice);
    onBotonSeleccionado(rutaSeleccionada);
  }

  List<BottomNavigationBarItem> construirNavegacion(BuildContext context) {
    List<BottomNavigationBarItem> navegacion = [];

    for (var ruta in Ruta.values) {
      var destination = BottomNavigationBarItem(
        backgroundColor: DesignSystem.backgroundColor,
        icon: Icon(ruta.icon),
        activeIcon: Icon(ruta.icon),
        tooltip: ruta.nombre,
        label: ruta.nombre,
      );

      navegacion.add(destination);
    }

    return navegacion;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: rutaSeleccionada.index,
      selectedItemColor: DesignSystem.accionPrimaria,
      backgroundColor: DesignSystem.backgroundColor,
      unselectedItemColor: const Color.fromARGB(255, 197, 196, 196),
      enableFeedback: false,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      selectedIconTheme: const IconThemeData(
        size: 22,
        color: DesignSystem.accionPrimaria,
      ),
      unselectedIconTheme: const IconThemeData(size: 22),
      onTap: _manejarIndiceSeleccionado,
      items: [
        ...construirNavegacion(context),
      ],
    );
  }
}
