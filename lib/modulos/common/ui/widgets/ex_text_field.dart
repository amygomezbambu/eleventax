import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';

// TODO: Valores temporales, extraer en DesignSystem
const _fontFamily = 'Inter';
const _fontSizeXS = 15.0;
const _fontSizeMD = 14.0;

typedef ValidadorTextField = Future<String?> Function(String? value)?;

enum InputType { texto, numerico, moneda }

class ExTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final double? width;
  final IconData? icon;
  final GlobalKey? fieldKey;
  final InputType inputType;

  /// Evento lanzado cuando el widget pierde el foco,
  /// usualmente usado para validaciones
  final Function? onExit;

  final ValidadorTextField validator;

  const ExTextField(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.prefixText,
      this.suffixText,
      this.helperText,
      this.width,
      this.icon,
      this.fieldKey,
      this.onExit,
      this.validator,
      this.inputType = InputType.texto})
      : super(key: key);

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
                helperText: helperText,
                icon: icon,
                onExit: onExit,
                validator: validator,
                fieldKey: fieldKey,
                inputType: inputType),
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
                helperText: helperText,
                icon: icon,
                onExit: onExit,
                fieldKey: fieldKey,
                validator: validator,
                inputType: inputType,
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

class _ExTextField extends StatefulWidget {
  final TextEditingController controller;
  final double tamanoFuente;
  final String? prefixText;
  final String? suffixText;
  final String? helperText;
  final IconData? icon;
  final Function? onExit;
  final GlobalKey? fieldKey;
  final ValidadorTextField validator;
  final String hintText;
  final InputType inputType;

  const _ExTextField({
    Key? key,
    required this.controller,
    required this.tamanoFuente,
    this.prefixText,
    this.suffixText,
    this.helperText,
    this.icon,
    this.onExit,
    this.fieldKey,
    required this.hintText,
    this.validator,
    required this.inputType,
  }) : super(key: key);

  @override
  State<_ExTextField> createState() => _ExTextFieldState();
}

class _ExTextFieldState extends State<_ExTextField> {
  final _enDesktop = LayoutValue(xs: true, md: false);
  String? _errValidacion;

  String _sanitizarNumerico(String cadena) {
    if (cadena.isEmpty) {
      return cadena;
    }

    if (cadena[cadena.length - 1] == '.') {
      cadena = cadena.substring(0, cadena.length - 1);
    }

    var arr = cadena.split('.');
    arr[0] = int.parse(arr[0]).toString();

    cadena = arr.length > 1 ? ('${arr[0]}.${arr[1]}') : (arr[0]);
    return cadena;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Focus(
        onFocusChange: (hasFocus) async {
          if (!hasFocus) {
            if (widget.inputType == InputType.numerico) {
              widget.controller.text =
                  _sanitizarNumerico(widget.controller.text);
            }

            // Solo al perder el foco, mandamos llamar al validador si existe...
            if (widget.validator != null) {
              _errValidacion = await widget.validator!(widget.controller.text);

              // Como perdimos el foco mandamos validar el campo de la forma para que se muestre
              // el error de validación del TextFormField
              if (widget.fieldKey is GlobalKey<FormFieldState>) {
                (widget.fieldKey as GlobalKey<FormFieldState>)
                    .currentState
                    ?.validate();
              } else {
                debugPrint(
                    '🚧 El campo no tiene asignado un fieldKey, se necesita para realizar la validación.');
              }
            }
          }

          if (widget.onExit == null) return;
          if (!hasFocus) {
            widget.onExit!();
          }
        },
        child: TextFormField(
            key: widget.fieldKey,
            controller: widget.controller,
            cursorColor: Colors.black,
            keyboardType: (widget.inputType == InputType.texto)
                ? TextInputType.text
                : const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: (widget.inputType == InputType.texto)
                ? null
                : [
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
            textInputAction: TextInputAction.next,
            autofocus: true,
            autovalidateMode: AutovalidateMode.disabled,
            style: TextStyle(
                fontSize: widget.tamanoFuente,
                fontFamily: _fontFamily,
                color: TailwindColors.trueGray[700],
                fontWeight: FontWeight.normal),
            validator: (value) {
              return _errValidacion;
            },
            decoration: InputDecoration(
                prefixText: widget.prefixText,
                suffixText: widget.suffixText,
                helperText: widget.helperText,
                helperStyle: const TextStyle(fontSize: 12),
                filled: true,
                isDense: true,
                fillColor: TailwindColors.blueGray[200],
                prefixIcon: (widget.icon != null)
                    ? Icon(
                        widget.icon,
                        color: TailwindColors.blueGray[400],
                      )
                    : null,
                hintText: (_enDesktop.resolve(context) == true)
                    ? widget.hintText
                    : null,
                errorStyle: TextStyle(color: TailwindColors.red[700]!),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: TailwindColors.red[700]!,
                    width: 1.0,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: TailwindColors.lightBlue[600]!,
                    width: 1.5,
                  ),
                ),
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
                    fontSize: widget.tamanoFuente,
                    color: TailwindColors.blueGray[400]))),
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
