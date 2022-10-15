import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eleventa/modulos/ventas/ui/ui_sale_item.dart';
import 'package:layout/layout.dart';

class ListadoArticulos extends StatelessWidget {
  final List<UiSaleItem> articulos;
  final void Function(int) onSelectItem;

  const ListadoArticulos(
      {required this.articulos, required this.onSelectItem, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final targetPlatform = Theme.of(context).platform;
    final soportaTouch = (targetPlatform == TargetPlatform.android ||
        targetPlatform == TargetPlatform.iOS);

    return ListView.separated(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: articulos.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
            dense: (context.breakpoint <= LayoutBreakpoint.sm),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://source.unsplash.com/random/200×200/?${articulos[index].description}',
                  // Le indicamos que que tamaño será la imagen para que consuma
                  // menos memoria aunque la imagen original sea más grande
                  cacheHeight: 50,
                  cacheWidth: 50,
                  fit: BoxFit.cover,
                )),
            subtitle: Text(articulos[index].code),
            selected: !soportaTouch && UiCart.isSelectedItem(articulos[index]),
            selectedColor: Colors.white,
            selectedTileColor: TailwindColors.coolGray[500],
            title: Text(
              articulos[index].description,
              style: GoogleFonts.openSans(fontWeight: FontWeight.w500),
            ),
            trailing: Wrap(
                spacing: (context.breakpoint >= LayoutBreakpoint.sm) ? 80 : 31,
                children: <Widget>[
                  Text(
                    '\$${double.parse(articulos[index].price).toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 18,
                        color: !soportaTouch &&
                                UiCart.isSelectedItem(articulos[index])
                            ? Colors.white
                            : const Color.fromARGB(255, 38, 119, 181),
                        fontWeight: FontWeight.w600),
                  )
                ]),
            onTap: () => {!soportaTouch ? onSelectItem(index) : true});
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
