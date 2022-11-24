import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:flutter/material.dart';

import 'package:eleventa/modulos/productos/ui/forma_producto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

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
      debugPrint('borrando producto');
      await eliminarProducto.exec();
    } catch (e) {
      debugPrint('Ocurrió un error al borrar: ${e.toString()}');
    }

    // TODO: Avisarle al listado de productos para que se actualcie
  }

  @override
  Widget build(BuildContext context, [bool mounted = true]) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modificar Producto'),
        actions: [
          Consumer(
            builder: (context, ref, child) => IconButton(
              icon: const Icon(Icons.delete),
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
          ),
        ],
      ),
      body: FormaProducto(context, producto: (producto as Producto)),
    );
  }
}
