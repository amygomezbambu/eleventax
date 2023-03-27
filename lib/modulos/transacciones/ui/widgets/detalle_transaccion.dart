import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/common/ui/widgets/texto_valor.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class DetalleTransaccion extends StatefulWidget {
  final String title;
  final UID ventaUid;

  const DetalleTransaccion(
      {super.key, required this.ventaUid, required this.title});

  @override
  State<DetalleTransaccion> createState() => _DetalleTransaccionState();
}

class _DetalleTransaccionState extends State<DetalleTransaccion> {
  final esDesktop = LayoutValue(xs: false, md: true);

  Future<VentaDto> _leerDetalleDeVenta(UID ventaUid) async {
    // Simulamos una lectura de la base de datos lenta
    await Future.delayed(const Duration(milliseconds: 500));

    final demoData = VentaDto();
    demoData.folio = ventaUid.toString();

    return demoData;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Integrar aqui la lectura del detalle de la venta
    return FutureBuilder<VentaDto>(
      future: _leerDetalleDeVenta(widget.ventaUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final venta = snapshot.data!;
          var articulos = Faker().lorem.words(5);

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
              TextoValor('Cobrado en', venta.cobradaEn.toString()),
              const TextoValor('Caja', 'Caja 1 (Windows)'),
              const Encabezado('Articulos'),
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
                        uniqueId: articulos[index],
                        productName: articulos[index],
                      ),
                      subtitle: const Text('122345'),
                      // selected: !soportaTouch &&
                      //     ventaEnProgreso.articuloSeleccionado ==
                      //         articulos[index],
                      // selectedColor: ColoresBase.neutral800,
                      // selectedTileColor: ColoresBase.neutral300,
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          articulos[index],
                          //style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ),
                      trailing: Wrap(
                          spacing: (context.breakpoint >= LayoutBreakpoint.sm)
                              ? 80
                              : 31,
                          children: const <Widget>[
                            Text(
                              '1.0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: ColoresBase.neutral500,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '12.33',
                              style: TextStyle(
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
                      children: const [
                        Encabezado('Pagos'),
                        TextoValor(
                          'Tarjeta de crédito',
                          '12.33',
                          tamanoFuente: TextSizes.textBase,
                        ),
                      ],
                    ),
                  ),
                  //const Spacer(),
                  const SizedBox(width: 60),
                  Expanded(
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
