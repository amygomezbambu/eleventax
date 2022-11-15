import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ListadoProductos extends ConsumerWidget {
  const ListadoProductos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(providerListadoProductos);

    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Column(
            children: [
              const TextField(
                decoration: InputDecoration(hintText: 'Buscar producto'),
              ),
              ExBotonPrimario(
                icon: Icons.abc,
                label: 'Crear producto',
                onTap: () => {GoRouter.of(context).go('/productos/nuevo')},
              )
            ],
          ),
        ),
        SizedBox(
          height: 500,
          child: Container(
            color: Colors.grey,
            child: ListView.builder(
              shrinkWrap: true, // Set
              itemCount: productos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(productos[index].nombre),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
