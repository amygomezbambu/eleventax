import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_maestro_detalle.dart';
import 'package:eleventa/modulos/ventas/read_models/pago.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransaccionDeVentaListItem extends ListadoResponsivoItem {
  final String label;
  // TODO: Cambiar por DTO de listado de ventas
  final VentaDto venta;
  final Widget child;

  TransaccionDeVentaListItem({
    required this.label,
    required this.venta,
    required this.child,
  });

  @override
  Widget buildTitle(BuildContext context, {bool seleccionado = false}) =>
      Text(label,
          style: const TextStyle(
            fontSize: 13,
            color: ColoresBase.neutral700,
          ));

  @override
  Widget? buildLeading(BuildContext context, {bool selecciondo = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(DateFormat('h:mm a').format(venta.cobradaEn!),
            style: const TextStyle(
              fontSize: 10,
              color: ColoresBase.neutral700,
            )),
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: _obtenerIconoFormaDePago(venta.pagos),
        ),
      ],
    );
  }

  @override
  Widget? buildSubtitle(BuildContext context, {bool selecciondo = false}) {
    return Text(
      venta.resumenArticulos.toString(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
        color: ColoresBase.neutral700,
      ),
    );
  }

  @override
  Widget? buildTrailing(BuildContext context, {bool selecciondo = false}) {
    return Text('\$${venta.total.toString()}');
  }

  @override
  Widget buildChildView(BuildContext context) {
    return child;
  }

  @override
  String tituloVentana() {
    return 'Venta #${venta.folio}';
  }

  Icon _obtenerIconoFormaDePago(List<PagoDto> formasDePago) {
    var icon = const Icon(
            Icons.money,
            color: ColoresBase.neutral700,
            //size: 20,
          );

    if (formasDePago.length > 1) {
      icon = const Icon(
        Icons.payments,
        color: ColoresBase.neutral700,
        //size: 20,
      );
    } else if (formasDePago.isNotEmpty) {
      switch (formasDePago.first.forma) {
        case 'Efectivo':
          icon = const Icon(
            Icons.money,
            color: ColoresBase.neutral700,
            //size: 20,
          );
          break;
        case 'Tarjeta de crédito/débito':
          icon = const Icon(
            Icons.credit_card,
            color: ColoresBase.neutral700,
            //size: 20,
          );
          break;
        case 'Transferencia electrónica':
          icon = const Icon(
            Icons.currency_exchange,
            color: ColoresBase.neutral700,
            //size: 20,
          );
          break;
        default:
          icon = const Icon(
            Icons.money,
            color: ColoresBase.neutral700,
            //size: 20,
          );
      }
    }

    return icon;
  }
}
