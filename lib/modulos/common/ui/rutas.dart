import 'package:flutter/material.dart';

/// Rutas de las Vistas de la app disponibles
enum Rutas {
  ventas("Ventas", Icons.shopping_bag),
  productos("Productos", Icons.inventory_2);

  const Rutas(this.nombre, this.icon);
  final String nombre;
  final IconData icon;
}
