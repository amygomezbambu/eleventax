import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/dependencies.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'modules/sales/ui/sales_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const EleventaApp());
}

class EleventaApp extends StatelessWidget {
  const EleventaApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eleventa',
      theme: ThemeData(
          //colorSchemeSeed: Colors.red,
          fontFamily: 'Open Sans',
          scaffoldBackgroundColor: const Color(0xFFF2F3F6),
          //useMaterial3: true,
          // Deshabilitamos el efecto "Splash" de Material
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent),
      home: SalesPage(title: 'Ventas'),
    );
  }
}
