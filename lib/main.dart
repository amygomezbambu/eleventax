import 'package:eleventa/dependencias.dart';
import 'package:eleventa/loader.dart';
import 'package:eleventa/modulos/common/ui/no_encontrado.dart';
import 'package:eleventa/modulos/common/ui/rutas.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';
import 'package:eleventa/modulos/common/ui/layout_principal.dart';
import 'package:go_router/go_router.dart';

import 'package:eleventa/modulos/productos/ui/vista_productos.dart';

void main() async {
  var loader = Loader();
  await loader.iniciar();

  runApp(ProviderScope(child: EleventaApp()));

  // La siguiente funcion presentará un error en la UI
  // si hay alguna excepcion no manejada
  FlutterError.onError = (FlutterErrorDetails details) {
    Dependencias.infra.logger().error(
          ex: details.exception,
          stackTrace: details.stack,
        );

    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Ocurrió un problema'),
      ),
      body: Center(child: Text(details.toString())),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Dependencias.infra.logger().error(ex: error, stackTrace: stack);
    return true;
  };
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class EleventaApp extends StatelessWidget {
  EleventaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        restorationScopeId: 'eleventa',
        //onGenerateTitle: (BuildContext context) => 'My Shop',
        theme: ThemeData(
          //colorSchemeSeed: Colors.blueAccent,
          fontFamily: 'Inter',
          scaffoldBackgroundColor:
              TailwindColors.blueGray[50], //const Color(0xFFF2F3F6),
          useMaterial3: true,
          // Deshabilitamos el efecto "Splash" de Material
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            // Definimos el layout comun para todas las rutas hijas
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: LayoutPrincipal(child: child)),
                ]);
          },
          routes: [
            GoRoute(
              path: '/',
              name: Rutas.ventas.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  // TODO: Construir el arreglo de rutas de forma dinamica en base al enum de Rutas

                  /// Para las vistas principales usamos [[NoTransitionPage]]
                  /// para evitar animaciones entre vistas principales
                  const NoTransitionPage(
                      child: VistaVentas(
                title: 'Ventas',
              )),
            ),
            GoRoute(
              path: '/productos',
              name: Rutas.productos.name,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: VistaProductos(
                  title: 'Productos',
                ),
              ),
            ),
          ])
    ],
    errorBuilder: (context, state) => const VistaNoEncontrado(),
  );
}
