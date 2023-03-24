<<<<<<< HEAD
import 'dart:async';
import 'dart:io';

import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/adaptador_impresion_windows.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/impresora_tickets_windows.dart';
import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/common/ui/widgets/texto_valor.dart';
<<<<<<< HEAD
=======
import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
=======
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:intl/intl.dart';
=======
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
import 'package:layout/layout.dart';

class DetalleTransaccion extends StatefulWidget {
  final String title;
  final UID ventaUid;
  final VentaDto venta;

  const DetalleTransaccion(
<<<<<<< HEAD
      {super.key,
      required this.venta,
      required this.ventaUid,
      required this.title});
=======
      {super.key, required this.ventaUid, required this.title});
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))

  @override
  State<DetalleTransaccion> createState() => _DetalleTransaccionState();
}

class _DetalleTransaccionState extends State<DetalleTransaccion> {
<<<<<<< HEAD
<<<<<<< HEAD
  final esDesktop = LayoutValue(xs: false, md: true);

=======
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
=======
  final esDesktop = LayoutValue(xs: false, md: true);

>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
  Future<VentaDto> _leerDetalleDeVenta(UID ventaUid) async {
    // Simulamos una lectura de la base de datos lenta
    await Future.delayed(const Duration(milliseconds: 500));

<<<<<<< HEAD
    return widget.venta;
  }
=======
    final demoData = VentaDto();
    demoData.folio = ventaUid.toString();
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))

  Future<void> _reImprimirTicket(VentaDto ventaCobrada) async {
    if (Platform.isWindows) {
      final adaptadorImpresion = AdaptadorImpresionWindows();
      final impresoraTickets = ImpresoraDeTicketsWindows(
        nombreImpresora: appConfig.nombreImpresora,
        anchoTicket: AnchoTicket.mm58,
      );

      adaptadorImpresion.impresoraTickets = impresoraTickets;
      unawaited(adaptadorImpresion.imprimirTicket(ventaCobrada));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Integrar aqui la lectura del detalle de la venta
    return FutureBuilder<VentaDto>(
      future: _leerDetalleDeVenta(widget.ventaUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final venta = snapshot.data!;
<<<<<<< HEAD
          var articulos = venta.articulos;
=======
          var articulos = Faker().lorem.words(5);
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))

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
<<<<<<< HEAD
                      onTap: () {
                        _reImprimirTicket(venta);
                      },
                      width: esDesktop.resolve(context) ? Sizes.p52 : Sizes.p48,
                      height: 60,
                    ),
                    const SizedBox(width: Sizes.p2),
=======
                      onTap: () {},
                      width: esDesktop.resolve(context) ? Sizes.p52 : Sizes.p48,
                      height: 60,
                    ),
<<<<<<< HEAD
                    const Spacer(flex: 11),
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
=======
                    const SizedBox(width: Sizes.p2),
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
                    ExBoton.secundario(
                      label: 'Realizar devolución',
                      icon: Iconos.receipt,
                      onTap: () {},
<<<<<<< HEAD
<<<<<<< HEAD
                      width: esDesktop.resolve(context) ? Sizes.p52 : Sizes.p48,
=======
                      width: 200,
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
=======
                      width: esDesktop.resolve(context) ? Sizes.p52 : Sizes.p48,
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
                      height: 60,
                    )
                  ],
                ),
              ),
<<<<<<< HEAD
<<<<<<< HEAD
              TextoValor(
                  'Cobrado en',
                  DateFormat(
                    'd MMMM y h:mm a',
                  ).format(venta.cobradaEn!)),
              const TextoValor('Caja', 'Caja 1 (Windows)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Encabezado('Articulos'),
                  Text('${articulos.length} articulos'),
                ],
              ),
=======
              const TextoValor('Cobrado en', '12 Septiembee 2023 12:00'),
=======
              TextoValor('Cobrado en', venta.cobradaEn.toString()),
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
              const TextoValor('Caja', 'Caja 1 (Windows)'),
              const Encabezado('Articulos'),
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
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
<<<<<<< HEAD
                        uniqueId: articulos[index].uid.toString(),
                        productName: articulos[index].productoNombre.toString(),
                      ),
                      subtitle: Text(articulos[index].productoCodigo.toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: ColoresBase.neutral500,
                              fontWeight: FontWeight.w500)),
=======
                        uniqueId: articulos[index],
                        productName: articulos[index],
                      ),
                      subtitle: const Text('122345'),
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
                      // selected: !soportaTouch &&
                      //     ventaEnProgreso.articuloSeleccionado ==
                      //         articulos[index],
                      // selectedColor: ColoresBase.neutral800,
                      // selectedTileColor: ColoresBase.neutral300,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
<<<<<<< HEAD
                          articulos[index].productoNombre.toString(),
                          textAlign: TextAlign.left,
=======
                          articulos[index],
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
                          //style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: Wrap(
<<<<<<< HEAD
                          runAlignment: WrapAlignment.spaceBetween,
                          spacing: (context.breakpoint >= LayoutBreakpoint.sm)
                              ? 80
                              : 31,
                          children: <Widget>[
                            Text(
                              'x ${articulos[index].cantidad.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
=======
                          spacing: (context.breakpoint >= LayoutBreakpoint.sm)
                              ? 80
                              : 31,
                          children: const <Widget>[
                            Text(
                              '1.0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
                                  fontSize: 18,
                                  color: ColoresBase.neutral500,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
<<<<<<< HEAD
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
=======
                              '12.33',
                              style: TextStyle(
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
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
<<<<<<< HEAD
<<<<<<< HEAD
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Encabezado('Pagos'),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: venta.pagos.length,
                          itemBuilder: (context, index) {
                            if (venta.pagos[index].forma == 'Efectivo') {
                              return Column(
                                children: [
                                  TextoValor(
                                    venta.pagos[index].forma.toString(),
                                    '\$${venta.pagos[index].monto.toString()}',
                                    tamanoFuente: TextSizes.textBase,
                                  ),
                                  TextoValor(
                                    '',
                                    'Pago con \$${venta.pagos[index].pagoCon.toString()}',
                                    tamanoFuente: TextSizes.textBase,
                                  ),
                                ],
                              );
                            } else {
                              return TextoValor(
                                venta.pagos[index].forma.toString(),
                                '\$${venta.pagos[index].monto.toString()}',
                                tamanoFuente: TextSizes.textBase,
                              );
                            }
                          },
=======
                  Flexible(
                    fit: FlexFit.tight,
=======
                  Expanded(
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Encabezado('Pagos'),
                        TextoValor(
                          'Tarjeta de crédito',
                          '12.33',
                          tamanoFuente: TextSizes.textBase,
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
                        ),
                      ],
                    ),
                  ),
                  //const Spacer(),
                  const SizedBox(width: 60),
<<<<<<< HEAD
<<<<<<< HEAD
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
                          itemBuilder: (context, index) => TextoValor(
                            venta.totalesDeImpuestos[index].nombreImpuesto
                                .toString(),
                            '\$${venta.totalesDeImpuestos[index].monto.toString()}',
                            tamanoFuente: TextSizes.textBase,
                          ),
                        ),
                        TextoValor(
                          'Total',
                          '\$${venta.total.toString()}',
=======
                  Flexible(
                    fit: FlexFit.tight,
=======
                  Expanded(
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
                    child: Column(
                      children: const [
                        Encabezado('Totales'),
                        TextoValor(
                          'Subtotal',
                          '212.33',
                          tamanoFuente: TextSizes.textBase,
                        ),
                        TextoValor(
                          'IVA 16%',
                          '65.13',
                          tamanoFuente: TextSizes.textBase,
                        ),
                        TextoValor(
                          'IEPS 8%',
                          '22.53',
                          tamanoFuente: TextSizes.textBase,
                        ),
                        TextoValor(
                          'Total',
                          '2122.50',
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
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

<<<<<<< HEAD
<<<<<<< HEAD
=======
class TextoValor extends StatelessWidget {
  final String campo;
  final String valor;
  final TextAlign align;
  final double tamanoFuente;

  const TextoValor(this.campo, this.valor,
      {super.key,
      this.align = TextAlign.right,
      this.tamanoFuente = TextSizes.textSm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        //color: Colors.cyan,
        child: Row(
          children: [
            SizedBox(
              //width: 150,
              child: Container(
                //color: Colors.green,
                child: Text(
                  campo,
                  textAlign: align,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: tamanoFuente,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                //color: Colors.amber,
                child: Text(valor,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: tamanoFuente,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
=======
>>>>>>> b63dc5c (feat - Se implementa diálogo de venta a granel (#480))
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
