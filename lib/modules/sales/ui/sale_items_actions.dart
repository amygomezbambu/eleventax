import 'package:flutter/material.dart';
import 'package:eleventa/modules/sales/ui/sale_item_action_button.dart';

class SaleItemsActions extends StatelessWidget {
  const SaleItemsActions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: const [
              SaleItemActionButton('Aumentar', Icons.person),
              SaleItemActionButton('Disminuir', Icons.person)
            ],
          ),
          Row(
            children: const [
              SaleItemActionButton('Venta Rápida', Icons.person),
              SaleItemActionButton('Asignar Cliente', Icons.person)
            ],
          ),
          Row(
            children: const [
              SaleItemActionButton('Aplicar Descuento', Icons.person),
              SaleItemActionButton('Convertir a \n cotización', Icons.person)
            ],
          )
        ],
      ),
    );
  }
}
