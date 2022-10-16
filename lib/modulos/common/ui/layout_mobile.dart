import 'package:eleventa/modulos/common/ui/design_system.dart';
import 'package:eleventa/modulos/common/ui/rutas.dart';
import 'package:flutter/material.dart';

class BarraNavegacionInferior extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexSelect;

  const BarraNavegacionInferior({
    Key? key,
    required this.selectedIndex,
    required this.onIndexSelect,
  }) : super(key: key);

  List<BottomNavigationBarItem> construirNavegacion(BuildContext context) {
    List<BottomNavigationBarItem> navegacion = [];

    modulosActuales.forEach((key, v) {
      var destination = BottomNavigationBarItem(
        backgroundColor: DesignSystem.backgroundColor,
        icon: Icon(v),
        activeIcon: Icon(v),
        tooltip: key,
        label: key,
      );

      navegacion.add(destination);
    });

    return navegacion;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: DesignSystem.accionPrimaria,
      //unselectedItemColor: const Color.fromARGB(255, 197, 196, 196),
      enableFeedback: false,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      selectedIconTheme: const IconThemeData(
        size: 22,
        color: DesignSystem.accionPrimaria,
      ),
      unselectedIconTheme: const IconThemeData(size: 22),
      onTap: onIndexSelect,
      items: [
        ...construirNavegacion(context),
      ],
    );
  }
}
