import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:eleventa/l10n/generated/l10n.dart';

class NuevoProducto extends StatelessWidget {
  //static const titulo = 'Nuevo Producto';
  final esDesktop = LayoutValue(xs: false, md: true);

  NuevoProducto({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final m = L10n.of(context);
    return VistaPrincipalScaffold(
        titulo: m.productos_nuevoProducto_titulo,
        child:
            FormaProducto(context, titulo: m.productos_nuevoProducto_titulo));
  }
}
