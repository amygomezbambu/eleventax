import 'dart:io';

import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/ex_mobile_scanner.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';

/// Representa un textfield para ingresar un código de barras
/// en mobile se muestra un botón para escanear el código usando la cámara del disposito
class ExCampoCodigoProducto extends StatefulWidget {
  final String hintText;
  final bool aplicarResponsividad;
  final TextEditingController controller;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onCodigoEscanado;
  final GlobalKey? fieldKey;
  final ValidadorTextField? validator;
  final FocusNode? focusNode;

  const ExCampoCodigoProducto({
    Key? key,
    required this.hintText,
    required this.controller,
    this.aplicarResponsividad = true,
    this.onFieldSubmitted,
    this.fieldKey,
    this.validator,
    this.focusNode,
    this.onCodigoEscanado,
  }) : super(key: key);

  @override
  State<ExCampoCodigoProducto> createState() => _ExCampoCodigoProductoState();
}

class _ExCampoCodigoProductoState extends State<ExCampoCodigoProducto> {
  @override
  Widget build(BuildContext context) {
    return ExTextField(
        //key: FormaProducto.txtCodigo,
        fieldKey: widget.fieldKey,
        hintText: widget.hintText,
        controller: widget.controller,
        focusNode: widget.focusNode,
        icon: Iconos.barcode,
        autofocus: true,
        aplicarResponsividad: widget.aplicarResponsividad,
        validarAlPerderFoco: false,
        onFieldSubmitted: widget.onFieldSubmitted,

        // Mostramos el icono para escanear solo en plataformas móviles
        suffixIcon: Platform.isIOS || Platform.isAndroid
            ? IconButton(
                onPressed: () async {
                  var valor = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const ExMobileScanner();
                      },
                    ),
                  );

                  if (valor != null) {
                    // Ingresamos el valor en el text edit
                    widget.controller.text = valor;
                    widget.focusNode?.requestFocus();

                    // Avisamos para que se siga procesando
                    if (widget.onCodigoEscanado != null) {
                      widget.onCodigoEscanado!(valor);
                    }
                  }
                },
                icon: const Icon(
                  Iconos.barcode_scan,
                  color: ColoresBase.neutral500,
                ),
              )
            : null,
        validator: widget.validator);
  }
}
