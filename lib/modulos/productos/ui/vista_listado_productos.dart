import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:eleventa/modulos/productos/ui/modificar_producto.dart';
import 'package:eleventa/modulos/productos/ui/nuevo_producto.dart';

class VistaListadoProductos extends StatefulWidget {
  const VistaListadoProductos({Key? key}) : super(key: key);

  @override
  State<VistaListadoProductos> createState() => VistaListadoProductosState();
}

class VistaListadoProductosState extends State<VistaListadoProductos> {
  var editando = false;
  Producto? producto;

  void _mandarModificarProducto(Producto value) {
    setState(() {
      editando = true;
      producto = value;
    });
  }

  void _mostrarNuevoProducto() {
    setState(() {
      editando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      md: (BuildContext context) => Scaffold(
        body: Row(
          children: [
            Flexible(
              flex: 2,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                child: _ListadoProductos(
                  onTap: _mandarModificarProducto,
                  onNuevoProducto: _mostrarNuevoProducto,
                ),
              ),
            ),
            Flexible(
              flex: 4,
              child: editando
                  ? ModificarProducto(producto: producto!)
                  : const NuevoProducto(),
            ),
          ],
        ),
      ),
      xs: (BuildContext context) => Scaffold(
          body: _ListadoProductos(
              onTap: _mandarModificarProducto,
              onNuevoProducto: _mostrarNuevoProducto)),
    );
  }
}

class _ListadoProductos extends ConsumerWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final Function(Producto) onTap;
  final VoidCallback onNuevoProducto;
  final controllerBusqueda = TextEditingController();

  _ListadoProductos({
    Key? key,
    required this.onTap,
    required this.onNuevoProducto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref, [bool mounted = true]) {
    final productos = ref.watch(providerListadoProductos);
    final scrollController = ScrollController();

    return Column(
      children: [
        SizedBox(
          height: 125,
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
                  ExTextField(
                    controller: controllerBusqueda,
                    hintText: 'Buscar productos',
                    onFieldSubmitted: (value) async {
                      try {
                        CodigoProducto codigo = CodigoProducto(value);

                        var producto =
                            await ModuloProductos.repositorioConsultaProductos()
                                .obtenerProductoPorCodigo(codigo);

                        if (!mounted) return;

                        if (producto == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Producto no encontrado!'),
                            ),
                          );
                        } else {
                          if (!esDesktop.resolve(context)) {
                            context.push(
                              '/productos/modificar',
                              extra: producto,
                            );
                          } else {
                            onTap(producto);
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código inválido!'),
                          ),
                        );
                      }

                      controllerBusqueda.clear();
                    },
                  ),
                  ExBotonPrimario(
                    icon: Icons.create_outlined,
                    label: 'Crear producto',
                    onTap: () => {
                      if (!esDesktop.resolve(context))
                        {GoRouter.of(context).go('/productos/nuevo')}
                      else
                        {onNuevoProducto()}
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Scrollbar(
            thumbVisibility: esDesktop.resolve(context),
            controller: scrollController,
            //scrollbarOrientation: ScrollbarOrientation.bottom,
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: productos.length,
              controller: scrollController,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    contentPadding: EdgeInsets.only(
                        top: 4.0,
                        bottom: 4.0,
                        left: (context.breakpoint >= LayoutBreakpoint.sm)
                            ? 4.0
                            : 10.0,
                        right: 15.0),
                    dense: (context.breakpoint <= LayoutBreakpoint.sm),
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
                          fontSize: esDesktop.resolve(context) ? 16 : 14,
                          fontWeight: FontWeight.w500),
                    ),
                    hoverColor: TailwindColors.blueGray[200],
                    trailing: Wrap(
                        spacing: (context.breakpoint >= LayoutBreakpoint.sm)
                            ? 80
                            : 31,
                        children: <Widget>[
                          Text(
                            productos[index].precioDeVenta.toString(),
                            style: TextStyle(
                                fontSize: esDesktop.resolve(context) ? 18 : 16,
                                color: const Color.fromARGB(255, 38, 119, 181),
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                    onTap: () => {
                          if (!esDesktop.resolve(context))
                            {
                              context.push('/productos/modificar',
                                  extra: productos[index])
                            }
                          else
                            {onTap(productos[index])}
                        });
              },
              separatorBuilder: (context, index) => Margin(
                margin: EdgeInsets.only(
                    left: (context.breakpoint >= LayoutBreakpoint.sm) ? 65 : 55,
                    right: 15,
                    top: 0.0,
                    bottom: 0.0),
                child: const Divider(
                    height: 0,
                    color: Color.fromARGB(255, 208, 208, 208),
                    thickness: 0.5),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
