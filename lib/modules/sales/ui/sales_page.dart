import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/ui/ui_consts.dart' as ui;
import '../../common/ui/primary_button.dart';
import 'sale_items_actions.dart';
import 'ui_sale_item.dart';
import 'sale_items_list.dart';

class SalesPage extends StatefulWidget {
  final String title;

  const SalesPage({Key? key, required this.title}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      // Desktop / Tablet view
      if (constraints.maxWidth >= 800) {
        return Scaffold(
            body: Row(
          children: [
            Container(
              color: ui.backgroundColor,
              width: 65,
            ),
            Expanded(
              child: Row(
                children: [
                  SaleItemsContainer(),
                ],
              ),
            ),
          ],
        ));
      } else {
        // Mobile
        return Scaffold(
            body: Column(
          children: [
            AppBar(
              toolbarHeight: 50,
              title: Text(
                MediaQuery.of(context).size.width > 800
                    ? 'eleventa desktop'
                    : 'eleventa móvil',
                style: GoogleFonts.openSans(),
              ),
              backgroundColor: ui.backgroundColor,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  color: const Color.fromARGB(255, 179, 224, 255),
                  tooltip: 'Agregar venta rápida',
                  onPressed: () {},
                )
              ],
              leading: const Icon(Icons.menu),
            ),
            SaleItemsContainer()
          ],
        ));
      }
    });
  }
}

class SaleItemsContainer extends StatefulWidget {
  const SaleItemsContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<SaleItemsContainer> createState() => _SaleItemsContainerState();
}

class _SaleItemsContainerState extends State<SaleItemsContainer> {
  @override
  Widget build(BuildContext context) {
    // TBD: Sacar el breakpoint para desktop de estandares o un paquete auxilair
    return MediaQuery.of(context).size.width > 800
        ? Expanded(
            child: Row(
              children: [
                const SaleItemsList(),
                Container(
                  width: 400,
                  padding: const EdgeInsets.fromLTRB(1, 5, 10, 5),
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SaleItemsActions(),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(3, 10, 5, 10),
                        height: 60,
                        child: PrimaryButton(
                            'Cobrar ${UiCart.total.toString()}',
                            Icons.attach_money_outlined),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        : Expanded(
            child: Column(
              children: [
                const SaleItemsList(),
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 60,
                  child: PrimaryButton('Cobrar ${UiCart.total.toString()}',
                      Icons.attach_money_outlined),
                )
              ],
            ),
          );
  }
}
