import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_acciones_dialogo.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:layout/layout.dart';

class DialogoVentaGranel extends StatefulWidget {
  final String nombreProducto;
  final Moneda precioDeVenta;

  const DialogoVentaGranel({
    Key? key,
    required this.nombreProducto,
    required this.precioDeVenta,
  }) : super(key: key);

  @override
  State<DialogoVentaGranel> createState() => _DialogoVentaRapidaState();
}

class _DialogoVentaRapidaState extends State<DialogoVentaGranel> {
  final esDesktop = LayoutValue(xs: false, md: true);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController cantidadController = TextEditingController();
  final keyCantidad = GlobalKey<FormFieldState<dynamic>>();
  late FocusNode _focusNode;
  Moneda _totalArticulo = Moneda(0.0);

  @override
  void initState() {
    super.initState();

    cantidadController.addListener(_actualizarImporteCalculado);
    _focusNode = FocusNode(debugLabel: "focusDialogoVentaGranel");
  }

  void _actualizarImporteCalculado() {
    final cantidad = double.tryParse(cantidadController.text);

    setState(() {
      _totalArticulo = Moneda(0.0);

      if (cantidad != null) {
        try {
          _totalArticulo = Moneda(widget.precioDeVenta.toDouble() *
              double.parse(cantidadController.text));
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  KeyEventResult _manejarTeclado(FocusNode focusNode, RawKeyEvent key) {
    if (key is RawKeyDownEvent) {
      if ((key.logicalKey == LogicalKeyboardKey.enter)) {
        _cerrarDialogo(context);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _cerrarDialogo(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      try {
        var cantidad = double.parse(cantidadController.text);
        Navigator.of(context, rootNavigator: true).pop(cantidad);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      debugLabel: 'DialogoVentaGranel',
      focusNode: _focusNode,
      canRequestFocus: false,
      onKey: (FocusNode focusNode, RawKeyEvent key) =>
          _manejarTeclado(focusNode, key),
      child: Form(
        key: _formKey,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _NombreProducto(nombreProducto: widget.nombreProducto),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: Sizes.p10,
                      right: Sizes.p10,
                      top: Sizes.p5,
                    ),
                    child: ExTextField(
                      fieldKey: keyCantidad,
                      hintText: 'Cantidad',
                      inputType: InputType.numerico,
                      aplicarResponsividad: false,
                      longitudMaxima: 6,
                      autofocus: true,
                      controller: cantidadController,
                      validator: (value) async {
                        if (value == null || value.isEmpty) {
                          return 'No puede estar vacio';
                        }

                        if (double.tryParse(cantidadController.text) == null) {
                          return 'No es un número';
                        }

                        if (double.parse(cantidadController.text) <= 0) {
                          return 'Cantidad debe ser mayor a cero';
                        }

                        if (double.parse(cantidadController.text) >= 99999999) {
                          return 'Cantidad incorrecta';
                        }

                        if (double.parse(cantidadController.text) < 0.0001) {
                          return 'La cantidad mínima debe ser 0.0001';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: Sizes.p2),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Sizes.p2,
                    ),
                    child: Container(
                      decoration: DesignSystem.separadorSuperior,
                      height: Sizes.p20,
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'Precio Unitario',
                                  style: TextStyle(
                                      fontSize: TextSizes.textSm,
                                      color: ColoresBase.neutral800,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  widget.precioDeVenta.toString(),
                                  style: const TextStyle(
                                      fontSize: TextSizes.textLg,
                                      color: ColoresBase.neutral800),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'Importe',
                                  style: TextStyle(
                                      fontSize: TextSizes.textSm,
                                      color: ColoresBase.neutral800,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(_totalArticulo.toString(),
                                    style: const TextStyle(
                                        fontSize: TextSizes.textLg,
                                        color: ColoresBase.neutral800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ExAccionesDeDialogo(
                accionPrimariaLabel: 'Agregar a venta',
                onTapAccionPrimaria: () {
                  _cerrarDialogo(context);
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

class _NombreProducto extends StatelessWidget {
  final String nombreProducto;

  const _NombreProducto({required this.nombreProducto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: DesignSystem.separadorInferior,
      child: Row(
        children: [
          AvatarProducto(productName: nombreProducto, uniqueId: nombreProducto),
          const SizedBox(width: Sizes.p3),
          Expanded(
            child: Text(nombreProducto,
                //textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: TextSizes.textLg,
                )),
          ),
        ],
      ),
    );
  }
}
