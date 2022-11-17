import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:flutter/material.dart';

class NuevoProducto extends StatelessWidget {
  const NuevoProducto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: FormaProducto(context),
    );
  }
}
