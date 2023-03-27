import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_maestro_detalle.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter/material.dart';

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
        Text(venta.cobradaEn.toString(),
            style: const TextStyle(
              fontSize: 10,
              color: ColoresBase.neutral700,
            )),
        const Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: Icon(
            Icons.credit_card,
            color: ColoresBase.neutral700,
            //size: 20,
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildSubtitle(BuildContext context, {bool selecciondo = false}) {
    return const Text(
      'Coca Cola 600ml, 2 x Tomate, 1 x Cebolla',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: ColoresBase.neutral700,
      ),
    );
  }

  @override
  Widget? buildTrailing(BuildContext context, {bool selecciondo = false}) {
    return Text(venta.total.toString());
  }

  @override
  Widget buildChildView(BuildContext context) {
    return child;
  }

  @override
  String tituloVentana() {
    return 'Venta #${venta.folio}';
  }
}
