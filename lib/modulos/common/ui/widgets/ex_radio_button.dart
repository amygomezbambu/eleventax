import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';

class ExRadioButton<T> extends StatelessWidget {
  final Function(T?) onChange;
  final T value;
  final T groupValue;
  final String label;
  final String hint;
  final double? width;

  const ExRadioButton({
    Key? key,
    required this.onChange,
    required this.value,
    required this.groupValue,
    required this.label,
    required this.hint,
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
            child: _ExRadioButton(
              onChange: onChange,
              value: value,
              groupValue: groupValue,
              label: label,
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
                padding: const EdgeInsets.only(right: Sizes.p2_5),
                child: EditLabel(
                  hintText: hint,
                  tamanoFuente: DesignSystem.campoTamanoTexto,
                ),
              )),
          Flexible(
            child: ConditionalParentWidget(
              condition: (width != null),
              child: _ExRadioButton(
                onChange: onChange,
                value: value,
                groupValue: groupValue,
                label: label,
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

class _ExRadioButton<T> extends StatefulWidget {
  final Function(T?) onChange;
  final T value;
  final T groupValue;
  final String label;

  const _ExRadioButton({
    Key? key,
    required this.onChange,
    required this.value,
    required this.groupValue,
    required this.label,
  }) : super(key: key);

  @override
  State<_ExRadioButton<T>> createState() => _ExRadioButtonState<T>();
}

class _ExRadioButtonState<T> extends State<_ExRadioButton<T>> {
  @override
  Widget build(BuildContext context) {
    return RadioListTile<T>(
        activeColor: ColoresBase.primario600,
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(widget.label,
            style: const TextStyle(
                fontSize: DesignSystem.campoTamanoTexto,
                fontWeight: FontWeight.normal)),
        value: widget.value,
        toggleable: true,
        groupValue: widget.groupValue,
        onChanged: widget.onChange);
  }
}
