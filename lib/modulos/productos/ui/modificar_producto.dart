import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:eleventa/modulos/productos/ui/forma_producto.dart';

class ModificarProducto extends StatelessWidget {
  final Object producto;

  const ModificarProducto({
    Key? key,
    required this.producto,
  }) : super(key: key);

  Future<void> _eliminarProducto() async {
    var uidProducto = (producto as Producto).uid;
    var eliminarProducto = ModuloProductos.eliminarProducto();
    eliminarProducto.req.uidProducto = uidProducto;

    try {
      await eliminarProducto.exec();
    } catch (e) {
      debugPrint('Ocurrió un error al borrar: ${e.toString()}');
    }

    // TODO: Avisarle al listado de productos para que se actualcie
  }

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return VistaPrincipalScaffold(
        titulo: 'Nuevo Producto',
        actions: [
          Consumer(
            builder: (context, ref, child) => IconButton(
              icon: const Icon(Iconos.trash, color: Colors.white),
              tooltip: 'Eliminar producto',
              onPressed: () async {
                await _eliminarProducto();

                if (!mounted) return;

                // Solo aplicar en mobile
                if (context.breakpoint <= LayoutBreakpoint.sm) {
                  context.pop();
                }

                ref.read(providerListadoProductos.notifier).obtenerProductos();

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Producto eliminado con éxito!')));
              },
            ),
          )
        ],
        child: FormaProducto(context, producto: (producto as Producto)));
  }
}
