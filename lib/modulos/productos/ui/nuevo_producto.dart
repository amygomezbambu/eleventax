import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class NuevoProducto extends StatelessWidget {
  static const titulo = 'Nuevo Producto';
  final esDesktop = LayoutValue(xs: false, md: true);

  NuevoProducto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VistaPrincipalScaffold(
        titulo: NuevoProducto.titulo,
        child: FormaProducto(context, titulo: NuevoProducto.titulo));
  }
}
