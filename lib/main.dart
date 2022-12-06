import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_scaffold.dart';
import 'package:eleventa/modulos/loader/loader.dart';
import 'package:eleventa/modulos/common/ui/no_encontrado.dart';
import 'package:eleventa/modulos/common/ui/ruta.dart';
import 'package:eleventa/modulos/config/ui/vista_configuracion.dart';
import 'package:eleventa/modulos/productos/ui/modificar_producto.dart';
import 'package:eleventa/modulos/productos/ui/nuevo_producto.dart';
import 'package:eleventa/modulos/ventas/ui/vista_ventas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';
import 'package:go_router/go_router.dart';

import 'package:eleventa/modulos/productos/ui/vista_productos.dart';

Future<void> main() async {
  var loader = Loader();
  await loader.iniciar();

  runApp(const ProviderScope(child: EleventaApp()));

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

class EleventaApp extends StatefulWidget {
  const EleventaApp({Key? key}) : super(key: key);

  @override
  State<EleventaApp> createState() => _EleventaAppState();
}

class _EleventaAppState extends State<EleventaApp> {
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_manejarAtajosConTeclado);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_manejarAtajosConTeclado);
    super.dispose();
  }

  void _manejarAtajosConTeclado(RawKeyEvent value) {
    // Definimos los atajos para navegar a las distintas vistas
    // principales, de momento los mismos atajos que eleventa 5
    if (value is RawKeyDownEvent) {
      if (value.logicalKey == LogicalKeyboardKey.f1) {
        setState(() => _router.go('/ventas'));
      }

      if (value.logicalKey == LogicalKeyboardKey.f3) {
        setState(() => _router.go('/productos'));
      }
    }

    // TODO: Falta ver la maneara de actualizar el NavigationRail
    // para que refleje el boton seleccionado de la nueva seccion
    // probablemete con Provider para "avisarle" al LayoutPrincipal
    // que tiene un nuevo index
  }

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
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.red),
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/ventas',
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithBottomNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/ventas',
              name: Ruta.ventas.name,
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
                name: Ruta.productos.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                      child: VistaProductos(
                        title: 'Productos',
                      ),
                    ),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const NuevoProducto(),
                  ),
                  GoRoute(
                      path: 'modificar',
                      builder: (context, state) {
                        return ModificarProducto(
                          producto: state.extra!,
                        );
                      }),
                ]),
            GoRoute(
              path: '/configuracion',
              name: Ruta.configuracion.name,
              pageBuilder: (BuildContext context, GoRouterState state) =>
                  const NoTransitionPage(child: VistaConfiguracion()),
            ),
          ])
    ],
    errorBuilder: (context, state) => const VistaNoEncontrado(),
  );
}
