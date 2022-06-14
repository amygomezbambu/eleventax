import 'package:flutter/material.dart';
import 'dart:math';

void main() {
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

class Item {
  final String code;
  final String description;
  final String price;

  Item({required this.code, required this.description, required this.price});
}

class SalesContainer extends StatefulWidget {
  const SalesContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<SalesContainer> createState() => _SalesContainerState();
}

class _SalesContainerState extends State<SalesContainer> {
  List<Item> items = [];
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
                        child: TextField(onChanged: _setDescription),
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
