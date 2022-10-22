import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';

// TODO: Valores temporales, extraer en DesignSystem
const _fontFamily = 'Inter';
const _fontSizeXS = 14.0;
const _fontSizeMD = 14.0;

class ExTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? prefixText;
  final String? suffixText;
  final double? width;
  final IconData? icon;

  const ExTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.prefixText,
    this.suffixText,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      xs: (context) => Column(
        children: [
          // Solo encerramos el textifield en un SizedBox si tiene width
          ConditionalParentWidget(
            condition: (width != null),
            child: _ExTextField(
                hintText: hintText,
                controller: controller,
                tamanoFuente: _fontSizeXS,
                prefixText: prefixText,
                suffixText: suffixText,
                icon: icon),
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
              child: _ExTextField(
                  hintText: hintText,
                  controller: controller,
                  tamanoFuente: _fontSizeMD,
                  prefixText: prefixText,
                  suffixText: suffixText,
                  icon: icon),
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

class EditLabel extends StatelessWidget {
  final double tamanoFuente;

  const EditLabel({
    Key? key,
    required this.hintText,
    required this.tamanoFuente,
  }) : super(key: key);

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Text(
      hintText,
      textAlign: TextAlign.right,
      style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: tamanoFuente,
          color: TailwindColors.blueGray[600],
          fontWeight: FontWeight.w400),
    );
  }
}

class _ExTextField extends StatelessWidget {
  final _enDesktop = LayoutValue(xs: true, md: false);
  final TextEditingController controller;
  final double tamanoFuente;
  final String? prefixText;
  final String? suffixText;
  final IconData? icon;

  _ExTextField(
      {Key? key,
      required this.hintText,
      required this.controller,
      required this.tamanoFuente,
      this.prefixText,
      this.suffixText,
      this.icon})
      : super(key: key);

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
          controller: controller,
          cursorColor: Colors.black,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          autofocus: true,
          style: TextStyle(
              fontSize: tamanoFuente,
              fontFamily: _fontFamily,
              color: TailwindColors.trueGray[700],
              fontWeight: FontWeight.normal),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
          decoration: InputDecoration(
              prefixText: prefixText,
              suffixText: suffixText,
              //errorText: 'this is an error',
              filled: true,
              isDense: true,
              fillColor: TailwindColors.blueGray[200],
              prefixIcon: (icon != null)
                  ? Icon(
                      icon,
                      color: TailwindColors.blueGray[400],
                    )
                  : null,
              hintText: (_enDesktop.resolve(context) == true) ? hintText : null,
              //helperText: "Ingresa precios sin impuestos",
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
                ),
              ),
              hintStyle: TextStyle(
                  fontSize: tamanoFuente,
                  color: TailwindColors.blueGray[400]))),
    );
  }
}

class ConditionalParentWidget extends StatelessWidget {
  const ConditionalParentWidget({
    Key? key,
    required this.condition,
    required this.child,
    required this.parentBuilder,
  }) : super(key: key);

  final Widget child;
  final bool condition;
  final Widget Function(Widget child) parentBuilder;

  @override
  Widget build(BuildContext context) {
    return condition ? parentBuilder(child) : child;
  }
}
