import 'package:eleventa/modulos/productos/ui/modificar_producto.dart';
import 'package:eleventa/modulos/productos/ui/nuevo_producto.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/config/ui/vista_configuracion.dart';
import 'package:eleventa/modulos/productos/ui/vista_productos.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';

class Ruta {
  final String rutaURL;
  final String nombre;
  final IconData icon;
  final Widget Function(BuildContext, GoRouterState)? builder;
  final Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder;
  final List<Ruta> subRutas;

  Ruta({
    this.builder,
    this.pageBuilder,
    required this.rutaURL,
    required this.nombre,
    required this.icon,
    this.subRutas = const [],
  });
}

class Rutas {
  /// Rutas de las Vistas de la app disponibles
  /// el orden en que aparecen en la UI es el orden
  /// de cómo se definen en el listado
  static final List<Ruta> rutas = [
    Ruta(
      rutaURL: "/ventas",
      nombre: "Ventas",
      icon: Iconos.bag4,
      pageBuilder: (context, state) =>
          const NoTransitionPage(
        child: VistaVentas(
          title: 'Ventas',
        ),
      ),
    ),
    Ruta(
      rutaURL: "/productos",
      nombre: "Productos",
      icon: Iconos.box,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: VistaProductos(
          title: 'Productos',
        ),
      ),
      subRutas: [
        Ruta(
          rutaURL: "nuevo",
          nombre: "Nuevo",
          icon: Iconos.box,
          builder: (context, state) => const NuevoProducto(),
        ),
        Ruta(
          rutaURL: "modificar",
          nombre: "Modificar",
          icon: Iconos.edit,
          builder: (context, state) => ModificarProducto(
            productoId: (state.extra! as String),
          ),
        ),
      ],
    ),
    Ruta(
      rutaURL: "/configuracion",
      nombre: "Configuración",
      icon: Iconos.setting_24,
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: VistaConfiguracion()),
    ),
  ];

  static List<RouteBase> generarRutas() {
    var goRoutes = <GoRoute>[];
    var goSubRoutes = <GoRoute>[];

    for (var ruta in rutas) {
      goSubRoutes = [];
      if (ruta.subRutas.isNotEmpty) {
        for (var subRuta in ruta.subRutas) {
          var goSubRoute = GoRoute(
            path: subRuta.rutaURL,
            name: subRuta.nombre,
            pageBuilder: subRuta.pageBuilder,
            builder: subRuta.builder,
          );

          goSubRoutes.add(goSubRoute);
        }
      }

      var goRoute = GoRoute(
        path: ruta.rutaURL,
        name: ruta.nombre,
        pageBuilder: ruta.pageBuilder,
        builder: ruta.builder,
        routes: goSubRoutes,
      );

      goRoutes.add(goRoute);
    }

    return goRoutes;
  }
}
