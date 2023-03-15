import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/dismiss_keyboard.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';
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
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 1,
                      color: ColoresBase.neutral200,
                    ),
                  ),
                  color: ColoresBase.neutral100,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: _ListadoProductos(
                        onTap: _mandarModificarProducto,
                        onNuevoProducto: _mostrarNuevoProducto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
                flex: 4,
                child: Column(
                  children: [
                    Expanded(
                      child: editando
                          ? VistaModificarProducto(
                              productoId: producto!.uid.toString())
                          : NuevoProducto(),
                    )
                  ],
                )),
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
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: ColoresBase.neutral300,
                  ),
                ),
                color: ColoresBase.neutral200,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: esDesktop.resolve(context) ? Sizes.p3 : Sizes.p4,
                  bottom: 0,
                  left: Sizes.p2,
                  right: Sizes.p2,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: Sizes.p2),
                      child: ExTextField(
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
                    ),
                    (context.breakpoint >= LayoutBreakpoint.md)
                        ? ExBoton.secundario(
                            key: VistaListadoProductos.keyBotonCobrar,
                            icon: Icons.create_outlined,
                            label: 'Crear producto',
                            height: Sizes.p12,
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
            child: Material(
              type: MaterialType.transparency,
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
                      leading: AvatarProducto(
                        uniqueId: productos[index].uid.toString(),
                        productName: productos[index].nombre,
                      ),
                      title: Text(
                        productos[index].codigo.toString(),
                        style: const TextStyle(
                            fontSize: TextSizes.textSm,
                            color: ColoresBase.neutral500,
                            fontWeight: FontWeight.w400),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: Sizes.p2),
                        child: Text(
                          productos[index].nombre,
                          style: const TextStyle(
                              fontSize: TextSizes.textSm,
                              color: ColoresBase.neutral700,
                              fontWeight: FontWeight.w500),
                        ),
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
                      right: Sizes.p3, top: Sizes.p0, bottom: Sizes.p0),
                  child: Divider(
                      height: Sizes.p0,
                      color: ColoresBase.neutral300,
                      thickness: Sizes.p0_5),
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
