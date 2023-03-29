import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';

import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:layout/layout.dart';

class ListadoArticulos extends ConsumerWidget {
  final void Function(Articulo) onSeleccionarArticulo;

  const ListadoArticulos({required this.onSeleccionarArticulo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetPlatform = Theme.of(context).platform;
    final soportaTouch = (targetPlatform == TargetPlatform.android ||
        targetPlatform == TargetPlatform.iOS);

    final ventaEnProgreso = ref.watch(providerVenta);
    final List<Articulo> articulos = ventaEnProgreso.venta.articulos;

    return articulos.isEmpty
        ? const Scaffold(
            body: Center(
              child: Text('Sin articulos'),
            ),
          )
        : ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: articulos.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  dense: (context.breakpoint <= LayoutBreakpoint.sm),
                  leading: AvatarProducto(
                    uniqueId: articulos[index].producto.uid.toString(),
                    productName: articulos[index].descripcion,
                  ),
                  subtitle: Text(articulos[index].producto.codigo),
                  selected: !soportaTouch &&
                      ventaEnProgreso.articuloSeleccionado == articulos[index],
                  selectedColor: ColoresBase.neutral800,
                  selectedTileColor: ColoresBase.neutral300,
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      articulos[index].descripcion,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                  ),
                  trailing: Wrap(
                      spacing:
                          (context.breakpoint >= LayoutBreakpoint.sm) ? 80 : 31,
                      children: <Widget>[
                        Text(
                          '${articulos[index].cantidad}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              color: ColoresBase.neutral500,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          articulos[index].total.toString(),
                          style: TextStyle(
                              fontSize: 18,
                              color: !soportaTouch &&
                                      ventaEnProgreso.articuloSeleccionado ==
                                          articulos[index]
                                  ? Colores.accionPrimaria
                                  : Colores.accionPrimaria,
                              fontWeight: FontWeight.w600),
                        )
                      ]),
                  onTap: () => {
                        !soportaTouch
                            ? onSeleccionarArticulo(articulos[index])
                            : true
                      });
            },
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(left: 80, right: 15),
              child: Divider(
                height: 0,
                color: ColoresBase.neutral200,
                thickness: Sizes.px,
              ),
            ),
          );
  }
}

class CodigoDeProducto extends StatelessWidget {
  final bool esGenerico;
  final String codigoDeProducto;

  const CodigoDeProducto(
      {Key? key, required this.esGenerico, required this.codigoDeProducto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return esGenerico
        ? const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(
                Iconos.flash4,
                size: 14,
              ),
            ),
          )
        : Text(codigoDeProducto);
  }
}
