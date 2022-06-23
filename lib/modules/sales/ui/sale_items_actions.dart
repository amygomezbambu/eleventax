import 'package:flutter/material.dart';
import 'sale_item_action_button.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class SaleItemsActions extends StatelessWidget {
  const SaleItemsActions({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: const [
              SaleItemActionButton('Aumentar', CupertinoIcons.add_circled),
              SaleItemActionButton('Disminuir', CupertinoIcons.minus_circle)
            ],
          ),
          Row(
            children: const [
              SaleItemActionButton(
                  'Venta Rápida', CupertinoIcons.bag_badge_plus),
              SaleItemActionButton(
                  'Asignar Cliente', CupertinoIcons.person_badge_plus)
            ],
          ),
          Row(
            children: const [
              SaleItemActionButton('Aplicar Descuento', CupertinoIcons.percent),
              SaleItemActionButton(
                  'Convertir a cotización', CupertinoIcons.doc_checkmark)
            ],
          )
        ],
      ),
    ));
  }
}
