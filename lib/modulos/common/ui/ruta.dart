import 'package:flutter/material.dart';

/// Rutas de las Vistas de la app disponibles
/// el orden en que aparecen en la UI es el orden
/// de cómo se definen en el enum
enum Ruta {
  ventas("Ventas", Icons.shopping_bag),
  productos("Productos", Icons.inventory_2),
  configuracion("Configuración", Icons.settings);

  const Ruta(this.nombre, this.icon);
  final String nombre;
  final IconData icon;
}
