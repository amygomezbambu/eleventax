import 'package:eleventa/modules/common/infra/logger.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/ui/ui_consts.dart' as ui;
import '../../common/ui/primary_button.dart';
import 'sale_items_actions.dart';
import 'ui_sale_item.dart';
import 'sale_item_list_view.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';
import 'package:eleventa/modules/items/items_module.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/dependencies.dart';

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
              width: 70,
              padding: const EdgeInsets.only(top: 20),
              child: Column(children: const [
                NavigationButton(Icons.shopping_cart_outlined),
                NavigationButton(Icons.person),
                NavigationButton(Icons.inventory_2)
              ]),
            ),
            Expanded(
              child: Row(
                children: const [
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
            const SaleItemsContainer()
          ],
        ));
      }
    });
  }
}

class NavigationButton extends StatelessWidget {
  final IconData icon;

  const NavigationButton(
    this.icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Icon(
        icon,
        color: TailwindColors.blueGray.shade200,
      ),
    );
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
  double saleTotal = 0.0;
  String currentSaleId = '';
  FocusNode myFocusNode = FocusNode();
  TextEditingController myController = TextEditingController();
  @protected
  late final ILogger logger;

  @override
  initState() {
    super.initState();
    logger = Dependencies.infra.logger();
  }

  Future<void> addItemBySku(String value) async {
    // Obtenemos los Use cases...
    GetItem getItem = ItemsModule.getItem();
    //ChargeSale chargeSale = SalesModule.chargeSale();
    CreateSale createSale = SalesModule.createSale();
    AddSaleItem addItem = SalesModule.addSaleItem();

    late ItemDTO item;

    // Checamos tener una venta
    if (UiCart.saleUid == '') {
      UiCart.saleUid = createSale.exec();
      logger.info('Nueva venta creada $UiCart.saleUid');
    }

    for (var i = 1; i < 10; i++) {
      getItem.request.sku = i.toString();

      try {
        item = await getItem.exec();

        // Agregamos el articulo a la venta
        addItem.request.item.description = item.description;
        addItem.request.item.price = item.price;
        addItem.request.item.quantity = 1;
        addItem.request.saleUid = UiCart.saleUid;

        logger.info('Agregando ${item.description} a venta ${UiCart.saleUid}');
        var sale = await addItem.exec();

        // Solo re-construimos la UI en el ultimo elemento
        //if (i == 1000) {
        setState(() {
          // Si tuvimos exito, lo agregamos a la UI
          UiCart.items.add(UiSaleItem(
              code: item.sku,
              description: item.description,
              price: item.price.toString()));

          UiCart.selectedItem = UiCart.items.last;
          UiCart.total = sale.total;

          saleTotal = sale.total;
        });
        //}
      } on Exception catch (e) {
        if (e is AppException) {
          // ToDO: Mostramos mensaje de que no se encontró producto
          logger.warn(e.message);
        }
      }
    }

    myController.clear();
    myFocusNode.requestFocus();
  }

  void selectItem(int itemIndex) {
    setState(() {
      UiCart.selectedItem = UiCart.items[itemIndex];
    });

    myFocusNode.requestFocus();
  }

  void chargeButtonClick() async {
    debugPrint('Cobrando!');

    var chargeSale = SalesModule.chargeSale();

    chargeSale.request.paymentMethod = SalePaymentMethod.cash;
    chargeSale.request.saleUid = UiCart.saleUid;

    await chargeSale.exec();

    setState(() {
      saleTotal = 0.0;
    });

    UiCart.items.clear();
    UiCart.saleUid = '';

    myController.clear();
    myFocusNode.requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Gracias por su compra, ¡Vuelva pronto!'),
      width: 300,
      //margin: EdgeInsets.only(bottom: -100),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 30.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TBD: Sacar el breakpoint para desktop de estandares o un paquete auxilair
    return MediaQuery.of(context).size.width > 800
        ? Expanded(
            child: Row(
              children: [
                Expanded(
                  child: saleControls(),
                ),
                Container(
                  width: 350,
                  padding: const EdgeInsets.fromLTRB(1, 5, 7, 5),
                  child: Column(
                    children: [
                      const Expanded(
                        child: Card(
                          elevation: 1,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: SaleItemsActions(),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(3, 10, 5, 10),
                        height: 60,
                        child: PrimaryButton(
                            'Cobrar \$${saleTotal.toStringAsFixed(2)}',
                            Icons.attach_money_outlined,
                            chargeButtonClick),
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
                Expanded(child: saleControls()),
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 60,
                  child: PrimaryButton(
                      'Cobrar \$${saleTotal.toStringAsFixed(2)}',
                      Icons.attach_money_outlined,
                      chargeButtonClick),
                )
              ],
            ),
          );
  }

  Column saleControls() {
    return Column(
      children: [
        Card(
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: TailwindColors.blueGray[200], //ui.neutral300,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  key: const Key("skuField"),
                  obscureText: false,
                  autofocus: true,
                  focusNode: myFocusNode,
                  controller: myController,
                  onSubmitted: addItemBySku,
                  autocorrect: false,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        CupertinoIcons.barcode_viewfinder,
                        color: TailwindColors.blueGray[300],
                      ),
                      border: InputBorder.none,
                      hintText: "Escanea o ingresa un código de producto...",
                      hintStyle: TextStyle(
                          fontSize: 15, color: TailwindColors.blueGray[400])),
                ),
              ),
            )),
        Expanded(
            child:
                ItemsListView(items: UiCart.items, onSelectItem: selectItem)),
      ],
    );
  }
}
