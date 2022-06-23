import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui_sale_item.dart';
import 'package:flutter/cupertino.dart';
import '../../common/ui/ui_consts.dart' as ui;

class SaleItemsList extends StatefulWidget {
  SaleItemsList({
    Key? key,
  }) : super(key: key);

  @override
  State<SaleItemsList> createState() => _SaleItemsListState();
}

class _SaleItemsListState extends State<SaleItemsList> {
  FocusNode myFocusNode = FocusNode();
  TextEditingController myController = TextEditingController();

  final List<UiSaleItem> _items = [];
  String code = '';
  String price = '';
  String description = '';
  late UiSaleItem _selectedItem;

  void _handleSubmit(String value) {
    print(value);
    price = value;

    setState(() {
      _items.add(UiSaleItem(
          code: '1234', description: 'My description', price: '12.90'));
      _selectedItem = _items.last;
    });

    myController.clear();
    myFocusNode.requestFocus();
  }

  void selectItem(int itemIndex) {
    setState(() {
      _selectedItem = _items[itemIndex];
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
                    onSubmitted: _handleSubmit,
                    autocorrect: false,
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          CupertinoIcons.barcode_viewfinder,
                          color: TailwindColors.blueGray[300],
                        ),
                        border: InputBorder.none,
                        // focusedBorder: OutlineInputBorder(
                        //   borderSide: BorderSide(
                        //       color: TailwindColors.blueGray[200]!, width: 1.0),
                        // ),
                        // enabledBorder: OutlineInputBorder(
                        //   borderSide: BorderSide(color: Colors.red, width: 5.0),
                        // ),
                        hintText: "Escanea o ingresa un código de producto...",
                        hintStyle: TextStyle(
                            fontSize: 15, color: TailwindColors.blueGray[400])),
                  ),
                ),
              )),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                    dense: false, // TBD: Poner denso solo en pantallas chicas
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://source.unsplash.com/random/200×200/?' +
                              _items[index].description,
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                        )),
                    subtitle: Text(_items[index].code),
                    selected: _selectedItem == _items[index],
                    selectedColor: Colors.white,
                    selectedTileColor: TailwindColors.coolGray[700],
                    title: Text(
                      _items[index].description,
                      style: GoogleFonts.openSans(
                          fontSize: ui.defaultFontSize,
                          fontWeight: FontWeight.w500),
                    ),
                    trailing: Wrap(
                        spacing:
                            MediaQuery.of(context).size.width > 800 ? 80 : 31,
                        children: <Widget>[
                          //Text('3', style: TextStyle(fontSize: 16)),
                          Text(
                            '12.50',
                            style: TextStyle(
                                fontSize: 18,
                                //letterSpacing: -0.6,
                                color: _selectedItem == _items[index]
                                    ? Colors.white
                                    : Color.fromARGB(255, 38, 119, 181),
                                fontWeight: FontWeight.w600),
                          )
                        ]),
                    onTap: () => {selectItem(index)});
              },
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(left: 80, right: 15),
                child: Divider(
                    height: 0,
                    color: Color.fromARGB(255, 208, 208, 208),
                    thickness: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
