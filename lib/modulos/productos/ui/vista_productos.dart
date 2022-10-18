import 'package:eleventa/modulos/productos/ui/nuevo_producto.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class VistaProductos extends StatelessWidget {
  final String titulo;

  const VistaProductos({Key? key, required this.titulo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveBuilder(
        xs: (context) => Column(
          children: [const Text('Productos Mobile'), NuevoProducto(context)],
        ),
        md: (context) => Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Productos Desktop'),
                  NuevoProducto(context)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
