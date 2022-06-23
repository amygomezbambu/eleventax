import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui_sale_item.dart';
import 'package:flutter/cupertino.dart';
import '../../common/ui/ui_consts.dart' as ui;
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';
import 'package:eleventa/modules/items/items_module.dart';
import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:eleventa/modules/sales/domain/entity/sale.dart';
import 'package:eleventa/modules/sales/app/usecase/charge_sale.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/loader.dart';

class SaleItemsList extends StatefulWidget {
  SaleItemsList({
    Key? key,
  }) : super(key: key);

  @override
  State<SaleItemsList> createState() => _SaleItemsListState();
}

class _SaleItemsListState extends State<SaleItemsList> {
  //Function(String) saleCreated;
  FocusNode myFocusNode = FocusNode();
  TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("initState() called");
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
      print('Nueva venta creada $UiCart.saleUid');
    }

    getItem.request.sku = value;

    try {
      item = await getItem.exec();

      // Agregamos el articulo a la venta
      addItem.request.item.description = item.description;
      addItem.request.item.price = item.price;
      addItem.request.item.quantity = 1;
      addItem.request.saleUid = UiCart.saleUid;

      print('Agregando ${item.description} a venta ${UiCart.saleUid}');
      await addItem.exec();

      setState(() {
        // Si tuvimos exito, lo agregamos a la UI
        UiCart.items.add(UiSaleItem(
            code: item.sku,
            description: item.description,
            price: item.price.toString()));

        UiCart.selectedItem = UiCart.items.last;
      });
    } on Exception catch (e) {
      if (e is AppException) {
        print((e as AppException).message);
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
      ),
    );
  }
}

class ItemsListView extends StatelessWidget {
  final List<UiSaleItem> items;
  final void Function(int) onSelectItem;

  const ItemsListView(
      {required this.items, required this.onSelectItem, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final targetPlatform = Theme.of(context).platform;
    final touchBasedInput = (targetPlatform == TargetPlatform.android ||
        targetPlatform == TargetPlatform.iOS);

    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            dense: MediaQuery.of(context).size.width <
                800, // TBD: Poner denso solo en pantallas chicas
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://source.unsplash.com/random/200×200/?' +
                      items[index].description,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                )),
            subtitle: Text(items[index].code),
            selected: !touchBasedInput && UiCart.isSelectedItem(items[index]),
            selectedColor: Colors.white,
            selectedTileColor: TailwindColors.coolGray[500],
            title: Text(
              items[index].description,
              style: GoogleFonts.openSans(
                  fontSize: ui.defaultFontSize, fontWeight: FontWeight.w500),
            ),
            trailing: Wrap(
                spacing: MediaQuery.of(context).size.width > 800 ? 80 : 31,
                children: <Widget>[
                  Text(
                    '12.50',
                    style: TextStyle(
                        fontSize: 18,
                        color: !touchBasedInput &&
                                UiCart.isSelectedItem(items[index])
                            ? Colors.white
                            : Color.fromARGB(255, 38, 119, 181),
                        fontWeight: FontWeight.w600),
                  )
                ]),
            onTap: () => {!touchBasedInput ? onSelectItem(index) : true});
      },
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(left: 80, right: 15),
        child: Divider(
            height: 0,
            color: Color.fromARGB(255, 208, 208, 208),
            thickness: 0.5),
      ),
    );
  }
}
