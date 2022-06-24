import 'package:flutter/material.dart';
import 'modules/sales/ui/sales_page.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:eleventa/loader.dart';

void main() {
  var loader = Loader();
  loader.init();

  runApp(const EleventaApp());
}

class EleventaApp extends StatelessWidget {
  const EleventaApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eleventa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          //colorSchemeSeed: Colors.red,
          fontFamily: 'Open Sans',
          scaffoldBackgroundColor:
              TailwindColors.blueGray[50], //const Color(0xFFF2F3F6),
          //useMaterial3: true,
          // Deshabilitamos el efecto "Splash" de Material
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent),
      home: SafeArea(child: const SalesPage(title: 'Ventas')),
    );
  }
}
