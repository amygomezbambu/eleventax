import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:flutter/material.dart';

import 'package:eleventa/modulos/productos/ui/forma_producto.dart';

class ModificarProducto extends StatelessWidget {
  final Object producto;

  const ModificarProducto({
    Key? key,
    required this.producto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modificar Producto')),
      body: FormaProducto(context, producto: (producto as Producto)),
    );
  }
}
