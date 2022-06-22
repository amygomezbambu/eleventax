import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/usecase/get_item.dart';
import 'package:eleventa/modules/items/items_module.dart';
import 'package:eleventa/modules/sales/app/dto/basic_item.dart';
import 'package:eleventa/modules/sales/app/usecase/add_sale_item.dart';
import 'package:eleventa/modules/sales/app/usecase/create_sale.dart';
import 'package:eleventa/modules/sales/sales_module.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/dependencies.dart';
import 'package:eleventa/loader.dart';
import 'dart:math';

void main() {
  var loader = Loader();
  loader.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Eleventa',
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const TopNavigation(title: "Mi Super Negocio"),
        SalesContainer(),
        const Footer()
      ],
    ));
  }
}

class ItemUI {
  final String code;
  final String description;
  final String price;

  ItemUI({required this.code, required this.description, required this.price});
}

class SalesContainer extends StatefulWidget {
  const SalesContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<SalesContainer> createState() => _SalesContainerState();
}

class _SalesContainerState extends State<SalesContainer> {
  List<ItemUI> items = [];
  String code = '';
  String price = '';
  String description = '';
  ItemUI? selectedItem;

  var itemCount = 0;
  var saleUID = '';

  Future<void> getItem() async {
    GetItem getItem = ItemsModule.getItem();
    late ItemDTO item;

    getItem.request.sku = description;

    try {
      item = await getItem.exec();

      setState(() {
        items.add(ItemUI(
            code: item.sku,
            description: item.description,
            price: item.price.toString()));

        selectedItem = items.last;
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> addItem() async {
    CreateSale createSale = SalesModule.createSale();
    AddSaleItem addSaleItem = SalesModule.addSaleItem();

    if (itemCount == 0) {
      print('Creando venta...');
      saleUID = await createSale.exec();
    }

    var item = BasicItemDTO();
    item.description = description;
    // TBD: Validar excepciones de conversion de cadena
    item.price = double.parse(price);
    item.quantity = 1;
    print('Guardando item...');

    addSaleItem.request.saleUid = saleUID;
    addSaleItem.request.item = item;

    var saleItemCount = await addSaleItem.exec();
    print('Item guardado $saleItemCount');

    itemCount++;
  }

  void handleSubmit(String value) async {
    await getItem();
    // print(value);
    // price = value;

    // try {
    //   await addItem();

    //   setState(() {
    //     items.add(ItemUI(code: code, description: description, price: price));
    //     selectedItem = items.last;
    //     print('selectedItem establecido');
    //     print('La UI debe de estar actualizada');
    //   });
    // } catch (e) {
    //   if (e is DomainException) {
    //     print((e as DomainException).message);
    //   }

    //   print(e.toString());
    // }
  }

  void _setCode(String value) {
    code = value;
  }

  void _setDescription(String value) {
    description = value;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        child: TextField(
                          onChanged: _setDescription,
                        ),
                        width: 200,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        child: TextField(onChanged: _setCode),
                        width: 100,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        child: TextField(onSubmitted: handleSubmit),
                        width: 100,
                      ),
                    ),
                    //TextField(onSubmitted: null),
                    //TextField(onSubmitted: null)
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ...(items).map((item) {
                      return ListTile(
                        leading: Image.network(
                          'https://source.unsplash.com/random/900×700/?' +
                              item.description,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.description),
                        subtitle: Text(item.code),
                        onTap: () => {setState(() => selectedItem = item)},
                        tileColor:
                            item == selectedItem ? Colors.blueGrey : null,
                        trailing: Text(
                          item.price,
                          style: const TextStyle(fontSize: 30),
                        ),
                      );
                    }).toList()
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Container(
          color: Colors.lightBlue,
          height: 50,
        ),
      )
    ]);
  }
}

class TopNavigation extends StatelessWidget {
  final String title;

  const TopNavigation({
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Container(
          color: Colors.blue,
          height: 60,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(2.0),
                child: FlutterLogo(),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title,
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
