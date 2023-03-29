import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/common/ui/widgets/texto_valor.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/articulo.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:layout/layout.dart';

class DetalleTransaccion extends StatefulWidget {
  final String title;
  final UID ventaUid;
  final VentaDto venta;

  const DetalleTransaccion(
      {super.key,
      required this.venta,
      required this.ventaUid,
      required this.title});

  @override
  State<DetalleTransaccion> createState() => _DetalleTransaccionState();
}

class _DetalleTransaccionState extends State<DetalleTransaccion> {
  final esDesktop = LayoutValue(xs: false, md: true);

  Future<VentaDto> _leerDetalleDeVenta(UID ventaUid) async {
    // Simulamos una lectura de la base de datos lenta
    await Future.delayed(const Duration(milliseconds: 500));

    return widget.venta;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Integrar aqui la lectura del detalle de la venta
    return FutureBuilder<VentaDto>(
      future: _leerDetalleDeVenta(widget.ventaUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final venta = snapshot.data!;
          var articulos = venta.articulos;

          return SizedBox(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ExBoton.secundario(
                      label: 'Reimprimir ticket',
                      icon: Iconos.printer,
                      onTap: () {},
                      width: esDesktop.resolve(context) ? Sizes.p52 : Sizes.p48,
                      height: 60,
                    ),
                    const SizedBox(width: Sizes.p2),
                    ExBoton.secundario(
                      label: 'Realizar devolución',
                      icon: Iconos.receipt,
                      onTap: () {},
                      width: esDesktop.resolve(context) ? Sizes.p52 : Sizes.p48,
                      height: 60,
                    )
                  ],
                ),
              ),
              TextoValor('Cobrado en', DateFormat('h:mm a').format(venta.cobradaEn!)),
              const TextoValor('Caja', 'Caja 1 (Windows)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Encabezado('Articulos'),
                  Text('${articulos.length} articulos'),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: ColoresBase.neutral200,
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                padding: const EdgeInsets.all(20),
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: articulos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      dense: (context.breakpoint <= LayoutBreakpoint.sm),
                      leading: AvatarProducto(
                        uniqueId: articulos[index].uid.toString(),
                        productName: articulos[index].productoNombre.toString(),
                      ),
                      subtitle: Text(articulos[index].productoCodigo.toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: ColoresBase.neutral500,
                              fontWeight: FontWeight.w500)),
                      // selected: !soportaTouch &&
                      //     ventaEnProgreso.articuloSeleccionado ==
                      //         articulos[index],
                      // selectedColor: ColoresBase.neutral800,
                      // selectedTileColor: ColoresBase.neutral300,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          articulos[index].productoNombre.toString(),
                          textAlign: TextAlign.left,
                          //style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: Wrap(
                          runAlignment: WrapAlignment.spaceBetween,
                          spacing: (context.breakpoint >= LayoutBreakpoint.sm)
                              ? 80
                              : 31,
                          children: <Widget>[
                             Text(
                              'x ${articulos[index].cantidad.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: ColoresBase.neutral500,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '\$${articulos[index].precioDeVenta.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: ColoresBase.neutral500,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '\$${articulos[index].subtotal.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 18,
                                  color: Colores.accionPrimaria,
                                  fontWeight: FontWeight.w600),
                            )
                          ]),
                    );
                  },
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(left: 60, right: 0),
                    child: Divider(
                      height: 0,
                      color: ColoresBase.neutral200,
                      thickness: Sizes.px,
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        const Encabezado('Pagos'),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: venta.pagos.length,
                          itemBuilder: (context, index) =>  TextoValor(
                            venta.pagos[index].forma.toString(),
                            '\$${venta.pagos[index].monto.toString()}',
                            tamanoFuente: TextSizes.textBase,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //const Spacer(),
                  const SizedBox(width: 60),
                  Expanded(
                    child: Column(
                      children: [
                        const Encabezado('Totales'),
                        TextoValor(
                          'Subtotal',
                          '\$${venta.subtotal.toString()}',
                          tamanoFuente: TextSizes.textBase,
                        ),
                         ListView.builder(
                          shrinkWrap: true,
                          itemCount: venta.totalesDeImpuestos.length,
                          itemBuilder: (context, index) =>  TextoValor(
                            venta.totalesDeImpuestos[index].nombreImpuesto.toString(),
                            '\$${venta.totalesDeImpuestos[index].monto.toString()}',
                            tamanoFuente: TextSizes.textBase,
                          ),
                        ),
                        TextoValor(
                          'Total',
                          '\$${venta.total.toString()}',
                          tamanoFuente: TextSizes.textBase,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ]),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}

class Encabezado extends StatelessWidget {
  final String encabezado;

  const Encabezado(this.encabezado, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15.0,
        bottom: 15.0,
      ),
      child: Text(
        encabezado,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
