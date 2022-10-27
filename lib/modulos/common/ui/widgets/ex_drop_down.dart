import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';

const _fontSizeMD = 14.0;

class ExDropDown<T> extends StatelessWidget {
  final Function(T?) onChanged;
  final List<DropdownMenuItem<T>> items;
  final T value;
  final Key dropDownKey;
  final String hintText;
  final double? width;

  const ExDropDown({
    Key? key,
    required this.onChanged,
    required this.items,
    required this.value,
    required this.dropDownKey,
    required this.hintText,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      xs: (context) => Column(
        children: [
          // Solo encerramos el textifield en un SizedBox si tiene width
          ConditionalParentWidget(
            condition: (width != null),
            child: _ExDropDown(
              dropDownKey: dropDownKey,
              onChanged: onChanged,
              items: items,
              value: value,
            ),
            parentBuilder: (Widget child) => SizedBox(
              width: width,
              child: child,
            ),
          ),
        ],
      ),
      md: (context) => Row(
        children: [
          SizedBox(
              width: 160,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: EditLabel(
                  hintText: hintText,
                  tamanoFuente: _fontSizeMD,
                ),
              )),
          Flexible(
            child: ConditionalParentWidget(
              condition: (width != null),
              child: _ExDropDown(
                dropDownKey: dropDownKey,
                onChanged: onChanged,
                items: items,
                value: value,
              ),
              parentBuilder: (Widget child) => SizedBox(
                width: width,
                child: child,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ExDropDown<T> extends StatefulWidget {
  final Function(T?) onChanged;
  final List<DropdownMenuItem<T>> items;
  final T value;
  final Key dropDownKey;

  const _ExDropDown({
    Key? key,
    required this.onChanged,
    required this.items,
    required this.value,
    required this.dropDownKey,
  }) : super(key: key);

  @override
  State<_ExDropDown<T>> createState() => _ExDropDownState<T>();
}

class _ExDropDownState<T> extends State<_ExDropDown<T>> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<T>(
        key: widget.dropDownKey,
        value: widget.value,
        style: TextStyle(
            fontSize: 14.0,
            color: TailwindColors.trueGray[700],
            fontWeight: FontWeight.normal),
        borderRadius: BorderRadius.circular(5),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(top: 0, bottom: 0, left: 8, right: 10),
          filled: true,
          fillColor: TailwindColors.blueGray[200],
          //prefixIcon: Icon(Icons.category, color: TailwindColors.blueGray[400]),
          prefixIconColor: TailwindColors.blueGray[400],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: TailwindColors.blueGray[200]!,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: TailwindColors.lightBlue[600]!,
                width: 1.5,
              )),
        ),
        onChanged: widget.onChanged,
        items: widget.items,
      ),
    );
  }
}
