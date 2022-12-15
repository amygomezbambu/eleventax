import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
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
    Ruta rutaSeleccionada =
        Rutas.rutas.firstWhere((e) => Rutas.rutas.indexOf(e) == indice);
    onBotonSeleccionado(rutaSeleccionada);
  }

  List<BottomNavigationBarItem> construirNavegacion(BuildContext context) {
    List<BottomNavigationBarItem> navegacion = [];

    for (var ruta in Rutas.rutas) {
      var destination = BottomNavigationBarItem(
        backgroundColor: Colores.navegacionBackground,
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
      currentIndex: Rutas.rutas.indexOf(rutaSeleccionada),
      selectedItemColor: ColoresBase.primario100,
      backgroundColor: Colores.navegacionBackground,
      unselectedItemColor: ColoresBase.neutral400,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: TextSizes.textXs,
      unselectedFontSize: TextSizes.textXxs,
      selectedIconTheme: const IconThemeData(
        size: Sizes.p6,
        color: ColoresBase.primario500,
      ),
      unselectedIconTheme: const IconThemeData(size: Sizes.p5),
      onTap: _manejarIndiceSeleccionado,
      items: [
        ...construirNavegacion(context),
      ],
    );
  }
}
