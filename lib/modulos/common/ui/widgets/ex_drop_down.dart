import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';

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
              width: Sizes.p40,
              child: Padding(
                padding: const EdgeInsets.only(right: Sizes.p2),
                child: EditLabel(
                  hintText: hintText,
                  tamanoFuente: DesignSystem.campoTamanoTexto,
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
      padding: const EdgeInsets.only(bottom: Sizes.p2),
      child: DropdownButtonFormField<T>(
        key: widget.dropDownKey,
        value: widget.value,
        isDense: true,
        style: const TextStyle(
            fontSize: DesignSystem.campoTamanoTexto,
            color: ColoresBase.neutral700,
            fontWeight: FontWeight.normal,
            height: 0.0),
        borderRadius: BorderRadius.circular(Sizes.p1),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
              top: Sizes.p0, bottom: Sizes.p0, left: Sizes.p2, right: Sizes.p2),
          filled: true,
          fillColor: ColoresBase.white,
          prefixIconColor: ColoresBase.neutral700,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Sizes.p1),
            borderSide: const BorderSide(
              color: ColoresBase.neutral300,
              width: Sizes.px,
            ),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Sizes.p1),
              borderSide: const BorderSide(
                color: ColoresBase.neutral300,
                width: Sizes.px,
              )),
        ),
        onChanged: widget.onChanged,
        items: widget.items,
      ),
    );
  }
}
