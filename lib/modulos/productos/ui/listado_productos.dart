import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:go_router/go_router.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';

class ListadoProductos extends ConsumerWidget {
  const ListadoProductos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(providerListadoProductos);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 66,
            child: Card(
              color: TailwindColors.coolGray[100],
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // TODO: Mostrar buscador cuando tengamos la funcionalidad
                    // ExTextField(
                    //   controller: _controller,
                    //   hintText: 'Buscar productos',
                    // ),
                    ExBotonPrimario(
                      icon: Icons.create_outlined,
                      label: 'Crear producto',
                      onTap: () =>
                          {GoRouter.of(context).go('/productos/nuevo')},
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: false,
              itemCount: productos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    //dense: (context.breakpoint <= LayoutBreakpoint.sm),
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://source.unsplash.com/random/200×200/?${productos[index].nombre}',
                          // Le indicamos que que tamaño será la imagen para que consuma
                          // menos memoria aunque la imagen original sea más grande
                          cacheHeight: 50,
                          cacheWidth: 50,
                          fit: BoxFit.cover,
                        )),
                    title: Text(
                      productos[index].nombre,
                      style: TextStyle(
                          fontSize: 16,
                          color: TailwindColors.coolGray[800],
                          fontWeight: FontWeight.w500),
                    ),
                    selectedColor: Colors.white,
                    selectedTileColor: TailwindColors.coolGray[500],
                    trailing: Wrap(spacing: 10, children: <Widget>[
                      Text(
                        productos[index].precioDeVenta.toString(),
                        style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 38, 119, 181),
                            fontWeight: FontWeight.w600),
                      )
                    ]),
                    onTap: () => {debugPrint('prod seleccionado')});
              },
              separatorBuilder: (context, index) => const Padding(
                padding:
                    EdgeInsets.only(left: 80, right: 15, top: 5.0, bottom: 5.0),
                child: Divider(
                    height: 0,
                    color: Color.fromARGB(255, 208, 208, 208),
                    thickness: 0.5),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
