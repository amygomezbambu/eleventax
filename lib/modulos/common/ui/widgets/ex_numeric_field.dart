import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';

const _fontFamily = 'Inter';
const _fontSizeXS = 15.0;
const _fontSizeMD = 14.0;

class ExNumericField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final double? width;
  final IconData? icon;

  /// Evento lanzado cuando el widget pierde el foco,
  /// usualmente usado para validaciones
  final Function? onExit;

  const ExNumericField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.width,
    this.icon,
    this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      xs: (context) => Column(
        children: [
          // Solo encerramos el textifield en un SizedBox si tiene width
          ConditionalParentWidget(
            condition: (width != null),
            child: _ExNumericField(
              hintText: hintText,
              controller: controller,
              tamanoFuente: _fontSizeXS,
              prefixText: prefixText,
              suffixText: suffixText,
              helperText: helperText,
              icon: icon,
              onExit: onExit,
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
              child: _ExNumericField(
                hintText: hintText,
                controller: controller,
                tamanoFuente: _fontSizeMD,
                prefixText: prefixText,
                suffixText: suffixText,
                helperText: helperText,
                icon: icon,
                onExit: onExit,
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

class _ExNumericField extends StatelessWidget {
  final _enDesktop = LayoutValue(xs: true, md: false);
  final TextEditingController controller;
  final double tamanoFuente;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final IconData? icon;
  final Function? onExit;

  _ExNumericField({
    Key? key,
    required this.controller,
    required this.tamanoFuente,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.icon,
    this.onExit,
    required this.hintText,
  }) : super(key: key);

  final String hintText;

  @override
  Widget build(BuildContext context) {
    String sanitizar(String cadena) {
      if (cadena[cadena.length - 1] == '.') {
        cadena = cadena.substring(0, cadena.length - 1);
      }

      var arr = cadena.split('.');
      arr[0] = int.parse(arr[0]).toString();

      cadena = arr.length > 1 ? ('${arr[0]}.${arr[1]}') : (arr[0]);
      return cadena;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            controller.text = sanitizar(controller.text);
          }

          if (!hasFocus && onExit != null) {
            onExit!();
          }
        },
        child: TextFormField(
          controller: controller,
          cursorColor: Colors.black,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            TextInputFormatter.withFunction(
              (oldValue, newValue) {
                var reg = RegExp(r'^[0-9]\d{0,11}(\.\d{0,6})?$');

                if (newValue.text.isEmpty) {
                  return newValue;
                }
                if (!reg.hasMatch(newValue.text)) {
                  return oldValue;
                }

                return newValue;
              },
            ),
          ],
          autofocus: true,
          style: TextStyle(
              fontSize: tamanoFuente,
              fontFamily: _fontFamily,
              color: TailwindColors.trueGray[700],
              fontWeight: FontWeight.normal),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Porfavor intrduce un valor';
            }

            return null;
          },
          decoration: InputDecoration(
            prefixText: prefixText,
            suffixText: suffixText,
            helperText: helperText,
            helperStyle: const TextStyle(fontSize: 12),
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
                fontSize: tamanoFuente, color: TailwindColors.blueGray[400]),
          ),
        ),
      ),
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
