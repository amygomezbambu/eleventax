import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:flutter/material.dart';

/// Rutas de las Vistas de la app disponibles
/// el orden en que aparecen en la UI es el orden
/// de cómo se definen en el enum
enum Ruta {
  ventas("Ventas", Iconos.bag4),
  productos("Productos", Iconos.box),
  configuracion("Configuración", Iconos.setting_24);

  const Ruta(this.nombre, this.icon);
  final String nombre;
  final IconData icon;
}
