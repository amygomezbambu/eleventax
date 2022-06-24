import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ui_sale_item.dart';
import 'package:flutter/cupertino.dart';
import '../../common/ui/ui_consts.dart' as ui;
import 'package:eleventa/loader.dart';

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
                    '\$${double.parse(items[index].price).toStringAsFixed(2)}',
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
