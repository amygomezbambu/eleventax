import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/ui/ui_consts.dart' as ui;
import '../../common/ui/primary_button.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'sale_items_actions.dart';
import 'ui_sale_item.dart';
import 'sale_items_list.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
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
              color: Color.fromARGB(255, 179, 224, 255),
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
    return MediaQuery.of(context).size.width > 800
        ? Expanded(
            child: Row(
              children: [
                SaleItemsList(),
                Container(
                  width: 400,
                  //height: double.maxFinite,
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
                        child: const PrimaryButton(
                            'Cobrar 12,445.50', Icons.attach_money_outlined),
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
                SaleItemsList(),
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 60,
                  child: const PrimaryButton(
                      'Cobrar \$12,445.50', Icons.attach_money_outlined),
                )
              ],
            ),
          );
  }
}

// class TopNavigation extends StatelessWidget {
//   final String title;

//   const TopNavigation({
//     required this.title,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//             child: Container(
//           color: Colors.blue,
//           height: 60,
//           child: Row(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.all(2.0),
//                 child: FlutterLogo(),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(title,
//                     style: const TextStyle(fontSize: 20, color: Colors.white)),
//               ),
//             ],
//           ),
//         )),
//       ],
//     );
//   }
// }
