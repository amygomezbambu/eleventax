import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:flutter/material.dart';

class NuevoProducto extends StatelessWidget {
  const NuevoProducto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VistaPrincipalScaffold(
        titulo: 'Nuevo Producto', child: FormaProducto(context));
  }
}
