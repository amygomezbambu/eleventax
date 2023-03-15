import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_acciones_dialogo.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/read_models/producto_generico.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:layout/layout.dart';

class DialogoVentaRapida extends StatefulWidget {
  const DialogoVentaRapida({Key? key}) : super(key: key);

  @override
  State<DialogoVentaRapida> createState() => _DialogoVentaRapidaState();
}

class _DialogoVentaRapidaState extends State<DialogoVentaRapida> {
  final esDesktop = LayoutValue(xs: false, md: true);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final keyNombre = GlobalKey<FormFieldState<dynamic>>();
  final keyCantidad = GlobalKey<FormFieldState<dynamic>>();
  final keyPrecio = GlobalKey<FormFieldState<dynamic>>();
  late FocusNode _focusNode;
  late FocusNode focusPrecio;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode(debugLabel: "focusDialogoVentaRapida");
    focusPrecio = FocusNode(debugLabel: "focusPrecio");
  }

  @override
  void dispose() {
    focusPrecio.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  KeyEventResult _cambiarControlEnFoco(FocusNode focusNode, RawKeyEvent key) {
    if (key is RawKeyDownEvent) {
      if (key.logicalKey == LogicalKeyboardKey.arrowDown) {
        debugPrint('TODO: Cambiar control al de abajo');
        focusNode.nextFocus();
        return KeyEventResult.handled;
      }

      if (key.logicalKey == LogicalKeyboardKey.arrowUp) {
        debugPrint('TODO: Cambiar control al de arriba si hay uno');
        focusNode.previousFocus();
        return KeyEventResult.handled;
      }

      if ((key.logicalKey == LogicalKeyboardKey.enter)) {
        if (focusPrecio.hasFocus) {
          _concluirVentaRapida(context);
          return KeyEventResult.handled;
        }

        debugPrint(
            'TODO: Avanzar al siguiente control si existe o hacer submit si es el último control');
        focusNode.nextFocus();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _concluirVentaRapida(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final productoGenerico = ProductoGenericoDto(
          nombre: NombreProducto(nombreController.text),
          cantidad: double.parse(cantidadController.text),
          precio: PrecioDeVentaProducto(Moneda(precioController.text)));

      Navigator.of(context, rootNavigator: true).pop(productoGenerico);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      debugLabel: 'DialogoVentaRapida',
      focusNode: _focusNode,
      canRequestFocus: false,
      onKey: (FocusNode focusNode, RawKeyEvent key) =>
          _cambiarControlEnFoco(focusNode, key),
      child: Form(
        key: _formKey,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    ExTextField(
                        hintText: 'Nombre del producto',
                        fieldKey: keyNombre,
                        aplicarResponsividad: false,
                        controller: nombreController,
                        autofocus: true,
                        validator: (String? value) async {
                          if ((value == null) || (value.isEmpty)) {
                            return 'No se aceptan valores vacios';
                          }

                          {
                            try {
                              var nombreSanitizado = NombreProducto(value);

                              setState(() {
                                nombreController.text = nombreSanitizado.value;
                              });
                              return null;
                            } catch (e) {
                              if (e is ValidationEx) {
                                switch (e.tipo) {
                                  case TipoValidationEx.longitudInvalida:
                                    return 'El nombre no puede exceder 130 caracteres';
                                  case TipoValidationEx.valorVacio:
                                    return 'El nombre no puede exceder 130 caracteres';
                                  default:
                                    return e.message;
                                }
                              }

                              if (e is DomainEx) {
                                return e.message;
                              } else {
                                return e.toString();
                              }
                            }
                          }
                        }
                        // TODO: Agregar validacion de nombre para tener un NombreProducto('Chicles')
                        //width: !esDesktop.resolve(context) ? Sizes.p48 : null,
                        ),
                    const SizedBox(height: Sizes.p2),
                    Flex(
                      direction: Axis.horizontal,
                      children: [
                        // TODO: UI - Si en mobile poner botones de cantidad a la izquierda y derecha
                        ExTextField(
                          fieldKey: keyCantidad,
                          hintText: 'Cantidad',
                          inputType: InputType.numerico,
                          aplicarResponsividad: false,
                          controller: cantidadController,
                          width: Sizes.p36,
                          validator: (value) async {
                            if (value == null || value.isEmpty) {
                              return 'No puede estar vacio';
                            }

                            if (double.tryParse(cantidadController.text) ==
                                null) {
                              return 'No es un número';
                            }

                            if (double.parse(cantidadController.text) <= 0) {
                              return 'Cantidad mayor a cero';
                            }
                            return null;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.all(Sizes.p2),
                          child: Text(' x ',
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: TextSizes.textSm,
                                  color: ColoresBase.neutral800,
                                  fontWeight: FontWeight.w400)),
                        ),

                        Expanded(
                          child: ExTextField(
                            fieldKey: keyPrecio,
                            hintText: 'Precio',
                            aplicarResponsividad: false,
                            inputType: InputType.moneda,
                            focusNode: focusPrecio,
                            controller: precioController,
                            validator: (value) async {
                              if (value == null || value.isEmpty) {
                                return 'No puede estar vacio';
                              }

                              try {
                                var precioSanitizado =
                                    PrecioDeVentaProducto(Moneda(value));
                                setState(() {
                                  precioController.text =
                                      precioSanitizado.value.toString();
                                });
                                return null;
                              } catch (e) {
                                if (e is DomainEx) {
                                  switch (e.tipo) {
                                    case TipoValidationEx.valorEnCero:
                                      return 'Ingresa un precio mayor a cero';
                                    default:
                                      return e.message;
                                  }
                                } else {
                                  return e.toString();
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ExAccionesDeDialogo(
                accionPrimariaLabel: 'Agregar a venta',
                onTapAccionPrimaria: () {
                  _concluirVentaRapida(context);
                },
                onTapAccionSecundaria: () {
                  Navigator.of(context, rootNavigator: true).pop(null);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
