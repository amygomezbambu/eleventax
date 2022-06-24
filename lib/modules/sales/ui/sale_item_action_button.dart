import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';

class SaleItemActionButton extends StatelessWidget {
  final String _label;
  final IconData _icon;

  const SaleItemActionButton(
    this._label,
    this._icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 130,
        child: Card(
          elevation: 0,
          margin: const EdgeInsets.all(7),
          color: TailwindColors.blueGray[200],
          shape: RoundedRectangleBorder(
              side: BorderSide(color: TailwindColors.blueGray[200]!, width: 1),
              borderRadius: BorderRadius.circular(5.0)),
          child: InkWell(
            hoverColor: TailwindColors.blueGray[300],
            highlightColor: TailwindColors.blueGray[400],
            borderRadius: BorderRadius.circular(5.0),
            onTap: () => {print('Se hizo clic en accion')},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _icon,
                  color: TailwindColors.blueGray[500],
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  _label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: TailwindColors.blueGray[600]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
