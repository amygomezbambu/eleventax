import 'package:eleventa/modulos/productos/ui/nuevo_producto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';

class VistaProductos extends StatelessWidget {
  final String titulo;

  const VistaProductos({Key? key, required this.titulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: AdaptiveBuilder(
            xs: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: NuevoProducto(context),
                )
              ],
            ),
            md: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 180, top: 20),
                  child: Text('Nuevo Producto',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: TailwindColors.blueGray[700])),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: NuevoProducto(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
