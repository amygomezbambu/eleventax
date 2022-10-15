import 'package:eleventa/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';
import 'package:eleventa/modulos/common/ui/layout_principal.dart';

void main() async {
  var loader = Loader();
  await loader.iniciar();

  runApp(const EleventaApp());
}

class EleventaApp extends StatelessWidget {
  const EleventaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: MaterialApp(
        title: 'eleventa',
        debugShowCheckedModeBanner: false,
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
        builder: (context, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: child!),
              ]);
        },
        home: const LayoutPrincipal(
          title: 'eleventa punto de venta',
        ),
      ),
    );
  }
}
