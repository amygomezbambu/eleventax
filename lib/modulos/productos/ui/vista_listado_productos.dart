import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/dismiss_keyboard.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:eleventa/modulos/productos/ui/vista_modificar_producto.dart';
import 'package:eleventa/modulos/productos/ui/nuevo_producto.dart';

class VistaListadoProductos extends StatefulWidget {
  static const keyBotonCobrar = Key('btnCrearProducto');

  const VistaListadoProductos({Key? key}) : super(key: key);

  @override
  State<VistaListadoProductos> createState() => VistaListadoProductosState();
}

class VistaListadoProductosState extends State<VistaListadoProductos> {
  final esDesktop = LayoutValue(xs: false, md: true);
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
      md: (BuildContext context) => VistaPrincipalScaffold(
        titulo: 'Productos',
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.p2_0),
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
                  ? VistaModificarProducto(productoId: producto!.uid.toString())
                  : NuevoProducto(),
            ),
          ],
        ),
      ),
      xs: (BuildContext context) => VistaPrincipalScaffold(
          titulo: 'Productos',
          actions: [
            IconButton(
              key: VistaListadoProductos.keyBotonCobrar,
              icon: const Icon(Iconos.add, color: Colors.white, size: Sizes.p6),
              tooltip: 'Crear Producto',
              onPressed: () async {
                context.go('/productos/nuevo');
                GoRouter.of(context).refresh();
              },
            )
          ],
          child: _ListadoProductos(
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
  final _scrollController = ScrollController(initialScrollOffset: Sizes.p0);

  _ListadoProductos({
    Key? key,
    required this.onTap,
    required this.onNuevoProducto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref, [bool mounted = true]) {
    final productos = ref.watch(providerListadoProductos);

    return Column(
      children: [
        SizedBox(
          height: esDesktop.resolve(context) ? Sizes.p28 : Sizes.p20,
          child: DismissKeyboard(
            child: Card(
              color: ColoresBase.neutral50,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.p0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: Sizes.p2_0,
                    bottom: 0,
                    left: Sizes.p2,
                    right: Sizes.p2),
                child: Column(
                  children: [
                    ExTextField(
                      controller: controllerBusqueda,
                      icon: Iconos.search,
                      autofocus: false,
                      hintText: 'Buscar productos',
                      aplicarResponsividad: false,
                      onFieldSubmitted: (value) async {
                        try {
                          CodigoProducto codigo = CodigoProducto(value);

                          var producto = await ModuloProductos
                                  .repositorioConsultaProductos()
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
                                extra: producto.uid.toString(),
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
                    (context.breakpoint >= LayoutBreakpoint.md)
                        ? ExBoton.primario(
                            key: VistaListadoProductos.keyBotonCobrar,
                            icon: Icons.create_outlined,
                            label: 'Crear producto',
                            height: Sizes.p10,
                            onTap: () async {
                              debugPrint(
                                  'Ir a crear producto, desktop: ${esDesktop.resolve(context)}');

                              if (!esDesktop.resolve(context)) {
                                context.go('/productos/nuevo');
                                GoRouter.of(context).refresh();
                              } else {
                                onNuevoProducto();
                              }
                            },
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: Sizes.p1),
          child: Scrollbar(
            thumbVisibility: esDesktop.resolve(context),
            trackVisibility: esDesktop.resolve(context),
            controller: _scrollController,
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: productos.length,
              controller: _scrollController,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    contentPadding: EdgeInsets.only(
                        top: Sizes.p1,
                        bottom: Sizes.p1,
                        left: (context.breakpoint > LayoutBreakpoint.sm)
                            ? Sizes.p2
                            : Sizes.p3,
                        right: Sizes.p3),
                    dense: (context.breakpoint <= LayoutBreakpoint.sm),
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(Sizes.p2),
                        child: Image.network(
                          'https://source.unsplash.com/random/200×200/?${productos[index].nombre}',
                          // Le indicamos que que tamaño será la imagen para que consuma
                          // menos memoria aunque la imagen original sea más grande
                          cacheHeight: Sizes.p12.toInt(),
                          cacheWidth: Sizes.p12.toInt(),
                          fit: BoxFit.cover,
                        )),
                    title: Text(
                      productos[index].nombre,
                      style: const TextStyle(
                          fontSize: TextSizes.textSm,
                          fontWeight: FontWeight.w500),
                    ),
                    hoverColor: ColoresBase.neutral300,
                    trailing: Wrap(
                        spacing: (context.breakpoint > LayoutBreakpoint.sm)
                            ? Sizes.p40
                            : Sizes.p28,
                        children: <Widget>[
                          Text(
                            productos[index].precioDeVenta.toString(),
                            style: TextStyle(
                                fontSize: esDesktop.resolve(context)
                                    ? TextSizes.textBase
                                    : TextSizes.textBase,
                                color: ColoresBase.primario600,
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                    onTap: () {
                      if (!esDesktop.resolve(context)) {
                        context.push('/productos/modificar',
                            extra: productos[index].uid.toString());
                      } else {
                        onTap(productos[index]);
                      }
                    });
              },
              separatorBuilder: (context, index) => const Margin(
                margin: EdgeInsets.only(
                    left: Sizes.p16,
                    right: Sizes.p3,
                    top: Sizes.p0,
                    bottom: Sizes.p0),
                child: Divider(
                    height: Sizes.p0,
                    color: ColoresBase.neutral300,
                    thickness: Sizes.p0_5),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
