import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/ui/ui_consts.dart' as ui;
import '../../common/ui/primary_button.dart';

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
          title: Text(
            'Ventas',
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
        SaleItemsContainer(),
        Container(
          margin: const EdgeInsets.all(10),
          height: 60,
          child: const PrimaryButton(
              'Cobrar \$12,445.50', Icons.attach_money_outlined),
        )
      ],
    ));
  }
}

class Item {
  final String code;
  final String description;
  final String price;

  Item({required this.code, required this.description, required this.price});
}

class SaleItemsContainer extends StatefulWidget {
  const SaleItemsContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<SaleItemsContainer> createState() => _SaleItemsContainerState();
}

class _SaleItemsContainerState extends State<SaleItemsContainer> {
  List<Item> items = [
    Item(code: '1234', description: 'Starbucks Coffee', price: '\$12.90'),
    Item(code: '789', description: 'Coke 4.5oz', price: '\$12.90'),
    Item(code: '32223', description: 'Donuts', price: '\$12.90'),
    Item(code: '43344', description: 'Tuna Sandwich', price: '\$12.90'),
    Item(code: '1234', description: 'Starbucks Coffee', price: '\$12.90'),
    Item(code: '789', description: 'Coke 4.5oz', price: '\$12.90'),
    Item(code: '32223', description: 'Donuts', price: '\$12.90'),
    Item(code: '43344', description: 'Tuna Sandwich', price: '\$12.90'),
    Item(code: '1234', description: 'Starbucks Coffee', price: '\$12.90'),
    Item(code: '789', description: 'Coke 4.5oz', price: '\$12.90'),
    Item(code: '32223', description: 'Donuts', price: '\$12.90'),
    Item(code: '43344', description: 'Tuna Sandwich', price: '\$12.90')
  ];
  String code = '';
  String price = '';
  String description = '';
  Item? selectedItem;

  void handleSubmit(String value) {
    print(value);
    price = value;

    setState(() {
      items.add(Item(code: code, description: description, price: price));
      selectedItem = items.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              dense: false, // TBD: Poner denso solo en pantallas chicas
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
              title: Text(
                items[index].description,
                style: GoogleFonts.openSans(
                    fontSize: ui.defaultFontSize, fontWeight: FontWeight.w500),
              ),
              trailing: Wrap(
                  spacing: MediaQuery.of(context).size.width > 800 ? 80 : 31,
                  children: const <Widget>[
                    //Text('3', style: TextStyle(fontSize: 16)),
                    Text(
                      '\$12.50',
                      style: TextStyle(
                          fontSize: 18,
                          //letterSpacing: -0.6,
                          color: Color.fromARGB(255, 38, 119, 181),
                          fontWeight: FontWeight.w600),
                    )
                  ]));
        },
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(left: 80, right: 15),
          child: Divider(
              height: 0,
              color: Color.fromARGB(255, 208, 208, 208),
              thickness: 0.5),
        ),
      ),
    );
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
