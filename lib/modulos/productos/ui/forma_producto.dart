import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/dismiss_keyboard.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_campo_codigo_producto.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_dialogos.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_drop_down.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_radio_button.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';

class FormaProducto extends StatefulWidget {
  static const txtNombre = Key('txtNombreProducto');
  static const btnGuardar = Key('btnGuardar');
  static const txtCodigo = Key('txtCodigo');
  static const txtPrecioCompra = Key('txtPrecioCompra');
  static const txtPrecioVenta = Key('txtPrecioVenta');
  static const cbxUnidadMedida = Key('cbxUnidadMedida');
  static const cbxImpuestos = Key('cbxImpuestos');
  static const cbxCategoria = Key('cbxCategoria');
  static const rdbSeVendePorUnidad = Key('rdbSeVendePorUnidad');
  static const rdbSeVendePorPeso = Key('rdbSeVendePorPeso');
  static const anchoCamposDefault = Sizes.p72;

  final String? productoEnModificacionId;
  final String titulo;

  const FormaProducto(BuildContext context,
      {Key? key, this.productoEnModificacionId, required this.titulo})
      : super(key: key);

  @override
  State<FormaProducto> createState() => _FormaProductoState();
}

typedef EstadoFormField = FormFieldState<String>;

class _FormaProductoState extends State<FormaProducto> {
  final esDesktop = LayoutValue(xs: false, md: true);
  final mostrarMargenLabel = LayoutValue(xs: false, md: true);
  Producto? productoEnModificacion;

  final FocusNode _focusNode = FocusNode();
  late FocusNode _codigoFocusNode;
  final scrollController = ScrollController(initialScrollOffset: 0.0);

  final keyCodigo = GlobalKey<FormFieldState<dynamic>>();
  final keyNombre = GlobalKey<FormFieldState<dynamic>>();
  final keyPrecioCompra = GlobalKey<FormFieldState<dynamic>>();
  final keyPrecioVenta = GlobalKey<FormFieldState<dynamic>>();
  final keyCategoria = GlobalKey<EstadoFormField>();
  final keyImpuestos = GlobalKey<EstadoFormField>();
  final keyUnidadDeMedida = GlobalKey<EstadoFormField>();

  final _formKey = GlobalKey<FormState>();

  final _imagenURL = GlobalKey<FormFieldState<dynamic>>();

  late final Future<List<Impuesto>> _impuestos = lecturas.obtenerImpuestos();
  late final Future<List<Categoria>> _categorias = lecturas.obtenerCategorias();
  late final Future<List<UnidadDeMedida>> _unidadesDeMedida =
      lecturas.obtenerUnidadesDeMedida();

  final _controllerCodigo = TextEditingController();
  final _controllerNombre = TextEditingController();
  final _controllerPrecioDeVenta = TextEditingController();
  final _controllerPrecioDeCompra = TextEditingController();
  final _controllerImagen = TextEditingController();
  final _controllerUtilidad = TextEditingController();

  final lecturas = ModuloProductos.repositorioConsultaProductos();
  bool _formaCargada = false;

  // Almacenamos el estado de las dropdowns seleccionados
  UnidadDeMedida? unidadDeMedidaSeleccionada;
  String unidadDeMedida = '';
  ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad;
  Categoria? categoriaSeleccionada;
  Impuesto? impuestoSeleccionado;

  void limpiarCampos() {
    _controllerCodigo.clear();
    _controllerImagen.clear();
    _controllerNombre.clear();
    _controllerPrecioDeCompra.clear();
    _controllerPrecioDeVenta.clear();
    _controllerUtilidad.clear();

    categoriaSeleccionada = null;
    impuestoSeleccionado = null;
    unidadDeMedidaSeleccionada = null;
    seVendePor = ProductoSeVendePor.unidad;

    _codigoFocusNode.requestFocus();
  }

  /// Cambia el control enfocado de acuerdo a las teclas de flecha arriba,
  /// flecha abajo y ENTER como en eleventa 5.
  void _cambiarControlEnFoco(KeyEvent key) {
    if (key.logicalKey == LogicalKeyboardKey.arrowDown) {
      debugPrint('TODO: Cambiar control al de abajo');
      return;
    }

    if (key.logicalKey == LogicalKeyboardKey.arrowUp) {
      debugPrint('TODO: Cambiar control al de arriba si hay uno');
      return;
    }

    if (key.logicalKey == LogicalKeyboardKey.enter) {
      debugPrint(
          'TODO: Avanzar al siguiente control si existe o hacer submit si es el último control');
      return;
    }
  }

  Future<void> _cargarFormaProducto() async {
    // Para evitar re-setear la forma cada que se manda llamar el build()
    // manejamos la siguiente bandera
    if (_formaCargada) {
      return;
    }

    // Reiniciamos el estado de validacion de los campos
    if (keyCodigo.currentState != null) {
      keyCodigo.currentState!.reset();
      keyNombre.currentState!.reset();
      keyPrecioCompra.currentState!.reset();
      keyPrecioVenta.currentState!.reset();
      _imagenURL.currentState!.reset();
    }

    if (widget.productoEnModificacionId != null) {
      productoEnModificacion = await lecturas
          .obtenerProducto(UID.fromString(widget.productoEnModificacionId!));
      _controllerCodigo.text = productoEnModificacion!.codigo;
      _controllerNombre.text = productoEnModificacion!.nombre;
      _controllerPrecioDeCompra.text =
          productoEnModificacion!.precioDeCompra.toDouble().toString();
      _controllerPrecioDeVenta.text =
          productoEnModificacion!.precioDeVenta.toDouble().toString();

      _controllerImagen.text = productoEnModificacion!.imagenURL;

      categoriaSeleccionada = productoEnModificacion!.categoria;
      unidadDeMedidaSeleccionada = productoEnModificacion!.unidadMedida;

      if (productoEnModificacion!.impuestos.isNotEmpty) {
        impuestoSeleccionado = productoEnModificacion!.impuestos.first;
      }

      seVendePor = productoEnModificacion!.seVendePor;
    }

    _formaCargada = true;
  }

  Categoria _obtenerSinCategoria() {
    return Categoria.cargar(
      uid: UID.invalid(),
      nombre: NombreCategoria.sinCategoria(),
      eliminado: false,
    );
  }

  @override
  void initState() {
    super.initState();

    _codigoFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _controllerCodigo.dispose();
    _controllerNombre.dispose();
    _controllerPrecioDeCompra.dispose();
    _controllerPrecioDeVenta.dispose();
    _controllerImagen.dispose();
    _controllerUtilidad.dispose();
    _focusNode.dispose();
    scrollController.dispose();

    _codigoFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FormaProducto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.productoEnModificacionId != oldWidget.productoEnModificacionId) {
      // Forzamos a que se vuelva a cargar la forma
      _formaCargada = false;
    }
  }

  Future<bool> _verificarExistenciaDeCodigo(String codigo) async {
    var consultas = ModuloProductos.repositorioConsultaProductos();

    if (productoEnModificacion == null) {
      return await consultas.existeProducto(codigo);
    } else {
      if (productoEnModificacion!.codigo != codigo) {
        return await consultas.existeProducto(codigo);
      }
    }

    return false;
  }

  Future<bool> _guardarProducto() async {
    bool operacionExitosa;
    if (productoEnModificacion == null) {
      operacionExitosa = await _crearProducto();
    } else {
      operacionExitosa = await _modificarProducto();
    }

    debugPrint(operacionExitosa.toString());
    return operacionExitosa;
  }

  Future<bool> _modificarProducto() async {
    var modificarProducto = ModuloProductos.modificarProducto();

    var productoModificado = _llenarProducto();
    productoModificado = productoModificado.copyWith(
      uid: productoEnModificacion!.uid,
    );

    modificarProducto.req.producto = productoModificado;

    try {
      await modificarProducto.exec();
      return true;
    } catch (e) {
      await ExDialogos.mostrarAdvertencia(context,
          titulo: 'No fue posible modificar producto', mensaje: e.toString());
      return false;
    }
  }

  Future<bool> _crearProducto() async {
    var crearProducto = ModuloProductos.crearProducto();

    try {
      Producto productoNuevo = _llenarProducto();

      crearProducto.req.producto = productoNuevo;

      await crearProducto.exec();

      setState(() {
        limpiarCampos();
      });

      return true;
    } catch (e) {
      debugPrint('No fue posible crear producto: $e');

      await ExDialogos.mostrarAdvertencia(context,
          titulo: 'No fue posible crear producto', mensaje: e.toString());

      return false;
    }
  }

  Producto _llenarProducto() {
    bool hayPrecioDeVenta = _controllerPrecioDeVenta.text.isNotEmpty;
    PrecioDeVentaProducto precioDeVenta;

    if (hayPrecioDeVenta) {
      precioDeVenta =
          PrecioDeVentaProducto(Moneda(_controllerPrecioDeVenta.text));
    } else {
      precioDeVenta = PrecioDeVentaProducto.sinPrecio();
    }

    var producto = Producto.crear(
      codigo: CodigoProducto(_controllerCodigo.text),
      nombre: NombreProducto(_controllerNombre.text),
      precioDeCompra:
          PrecioDeCompraProducto(Moneda(_controllerPrecioDeCompra.text)),
      seVendePor: seVendePor,
      categoria: categoriaSeleccionada,
      impuestos: [impuestoSeleccionado!],
      unidadDeMedida: unidadDeMedidaSeleccionada!,
      preguntarPrecio: !hayPrecioDeVenta,
      precioDeVenta: precioDeVenta,
      imagenURL: _controllerImagen.text,
    );
    return producto;
  }

  Future<String?> _validarCodigoIngresado(String? value) async {
    if (value == null) {
      return 'No se aceptan valores Nulos';
    }

    try {
      var codigoSanitizado = CodigoProducto(value);

      setState(() {
        _controllerCodigo.text = codigoSanitizado.value;
      });

      var existeCodigo =
          await _verificarExistenciaDeCodigo(codigoSanitizado.value);

      if (existeCodigo) {
        return 'El código ya existe, verificar';
      }

      return null;
    } catch (e) {
      if (e is DomainEx) {
        return e.message;
      } else {
        return e.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: FutureBuilder(
        future: _cargarFormaProducto(),
        builder: (BuildContext context, snapshot) {
          if (true) {
            return Scrollbar(
              thumbVisibility: esDesktop.resolve(context),
              trackVisibility: esDesktop.resolve(context),
              controller: scrollController,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.p4),
                  child: SizedBox(
                    width: Sizes.p96 * 2,
                    child: KeyboardListener(
                      focusNode: _focusNode,
                      onKeyEvent: (KeyEvent key) => _cambiarControlEnFoco(key),
                      child: FocusTraversalGroup(
                        policy: OrderedTraversalPolicy(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  esDesktop.resolve(context)
                                      ? TituloForma(widget: widget)
                                      : const SizedBox(),
                                  ExCampoCodigoProducto(
                                      key: FormaProducto.txtCodigo,
                                      fieldKey: keyCodigo,
                                      focusNode: _codigoFocusNode,
                                      controller: _controllerCodigo,
                                      hintText: 'Código',
                                      validator: (value) async {
                                        return _validarCodigoIngresado(value);
                                      }),
                                  ExTextField(
                                      key: FormaProducto.txtNombre,
                                      fieldKey: keyNombre,
                                      hintText: 'Nombre',
                                      controller: _controllerNombre,
                                      validator: (value) async {
                                        if (value == null) {
                                          return 'No se aceptan valores vacios';
                                        }

                                        try {
                                          var nombreSanitizado =
                                              NombreProducto(value);

                                          setState(() {
                                            _controllerNombre.text =
                                                nombreSanitizado.value;
                                          });
                                          return null;
                                        } catch (e) {
                                          if (e is ValidationEx) {
                                            switch (e.tipo) {
                                              case TipoValidationEx
                                                  .longitudInvalida:
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
                                      }),
                                  FutureBuilder<List<Categoria>>(
                                      future: _categorias,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Categoria>>
                                              snapshot) {
                                        if ((snapshot.hasData) &&
                                            (snapshot.data!.isNotEmpty)) {
                                          List<Categoria> listadoCategorias =
                                              snapshot.data!;
                                          if (UID.isValid(listadoCategorias
                                              .first.uid
                                              .toString())) {
                                            listadoCategorias.insert(
                                              0,
                                              _obtenerSinCategoria(),
                                            );
                                          }

                                          categoriaSeleccionada ??=
                                              listadoCategorias.first;

                                          return ExDropDown<Categoria>(
                                            key: FormaProducto.cbxCategoria,
                                            hintText: 'Categoría',
                                            dropDownKey: keyCategoria,
                                            value: categoriaSeleccionada!,
                                            onChanged: (Categoria? categoria) {
                                              setState(() {
                                                categoriaSeleccionada =
                                                    categoria!;
                                              });
                                            },
                                            items: listadoCategorias.map<
                                                    DropdownMenuItem<
                                                        Categoria>>(
                                                (Categoria value) {
                                              return DropdownMenuItem<
                                                  Categoria>(
                                                value: value,
                                                child: Text(value.nombre),
                                              );
                                            }).toList(),
                                          );
                                        } else {
                                          return const SizedBox(
                                              // width: Sizes.p5,
                                              // height: Sizes.p5,
                                              // child: CircularProgressIndicator(),
                                              );
                                        }
                                      }),
                                  ExRadioButton<ProductoSeVendePor>(
                                      key: FormaProducto.rdbSeVendePorUnidad,
                                      value: ProductoSeVendePor.unidad,
                                      groupValue: seVendePor,
                                      label: 'Unidad',
                                      hint: 'Se vende por',
                                      onChange: (ProductoSeVendePor? value) {
                                        setState(() {
                                          if (value != null) {
                                            seVendePor = value;
                                          }
                                        });
                                      }),
                                  ExRadioButton<ProductoSeVendePor>(
                                      key: FormaProducto.rdbSeVendePorPeso,
                                      value: ProductoSeVendePor.peso,
                                      groupValue: seVendePor,
                                      label: 'Peso',
                                      hint: '',
                                      onChange: (ProductoSeVendePor? value) {
                                        setState(() {
                                          if (value != null) {
                                            seVendePor = value;
                                          }
                                        });
                                      }),

                                  FutureBuilder<List<UnidadDeMedida>>(
                                      future: _unidadesDeMedida,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<UnidadDeMedida>>
                                              snapshot) {
                                        if ((snapshot.hasData) &&
                                            (snapshot.data!.isNotEmpty)) {
                                          List<UnidadDeMedida>
                                              listadoUnidadesDeMedida =
                                              snapshot.data!;

                                          unidadDeMedidaSeleccionada ??=
                                              listadoUnidadesDeMedida.first;

                                          return ExDropDown<UnidadDeMedida>(
                                            key: FormaProducto.cbxUnidadMedida,
                                            hintText: 'Unidad de Medida',
                                            width: FormaProducto
                                                .anchoCamposDefault,
                                            dropDownKey: keyUnidadDeMedida,
                                            value: unidadDeMedidaSeleccionada!,
                                            onChanged: (UnidadDeMedida?
                                                unidadDeMedida) {
                                              setState(() {
                                                unidadDeMedidaSeleccionada =
                                                    unidadDeMedida!;
                                              });
                                            },
                                            items: listadoUnidadesDeMedida.map<
                                                    DropdownMenuItem<
                                                        UnidadDeMedida>>(
                                                (UnidadDeMedida value) {
                                              return DropdownMenuItem<
                                                  UnidadDeMedida>(
                                                value: value,
                                                child: Text(value.nombre),
                                              );
                                            }).toList(),
                                          );
                                        } else {
                                          return const SizedBox();
                                          // return const SizedBox(
                                          //   width: Sizes.p5,
                                          //   height: Sizes.p5,
                                          //   child: CircularProgressIndicator(),
                                          // );
                                        }
                                      }), //loaading, //ya termine
                                  FutureBuilder<List<Impuesto>>(
                                      future: _impuestos,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<Impuesto>>
                                              snapshot) {
                                        if ((snapshot.hasData) &&
                                            (snapshot.data!.isNotEmpty)) {
                                          List<Impuesto> listadoImpuestos =
                                              snapshot.data!;
                                          impuestoSeleccionado ??=
                                              listadoImpuestos.first;

                                          return ExDropDown<Impuesto>(
                                            key: FormaProducto.cbxImpuestos,
                                            hintText: 'Impuesto',
                                            width: Sizes.p44,
                                            dropDownKey: keyImpuestos,
                                            value: impuestoSeleccionado!,
                                            onChanged: (Impuesto? impuesto) {
                                              setState(() {
                                                impuestoSeleccionado =
                                                    impuesto!;
                                              });
                                            },
                                            items: listadoImpuestos.map<
                                                    DropdownMenuItem<Impuesto>>(
                                                (Impuesto value) {
                                              return DropdownMenuItem<Impuesto>(
                                                value: value,
                                                child: Text(value.nombre),
                                              );
                                            }).toList(),
                                          );
                                        } else {
                                          // return const SizedBox(
                                          //   width: Sizes.p5,
                                          //   height: 20,
                                          //   child: CircularProgressIndicator(),
                                          // );
                                          return const SizedBox();
                                        }
                                      }),
                                  ExTextField(
                                    key: FormaProducto.txtPrecioCompra,
                                    fieldKey: keyPrecioCompra,
                                    hintText: 'Precio de compra',
                                    controller: _controllerPrecioDeCompra,
                                    //helperText: 'Con Impuestos',
                                    prefixText: '\$ ',
                                    width: Sizes.p44,
                                    inputType: InputType.numerico,
                                    validator: (value) async {
                                      if (value == null || value.isEmpty) {
                                        return 'No puede estar vacio';
                                      }

                                      try {
                                        var precioSanitizado =
                                            PrecioDeCompraProducto(
                                                Moneda(value));
                                        setState(() {
                                          _controllerPrecioDeCompra.text =
                                              precioSanitizado.value
                                                  .toDouble()
                                                  .toString();
                                        });
                                        return null;
                                      } catch (e) {
                                        if (e is DomainEx) {
                                          return e.message;
                                        } else {
                                          return e.toString();
                                        }
                                      }
                                    },
                                  ),
                                  // ExTextField(
                                  //   hintText: 'Utilidad',
                                  //   controller: _controllerUtilidad,
                                  //   suffixText: '%',
                                  //   width: 160,
                                  //   inputType: InputType.numerico,
                                  // ),
                                  ExTextField(
                                      key: FormaProducto.txtPrecioVenta,
                                      fieldKey: keyPrecioVenta,
                                      hintText: 'Precio de venta',
                                      controller: _controllerPrecioDeVenta,
                                      prefixText: '\$ ',
                                      width: Sizes.p44,
                                      inputType: InputType.numerico,
                                      validator: (value) async {
                                        if (value == null || value.isEmpty) {
                                          return 'No puede estar vacio';
                                        }

                                        try {
                                          var precioSanitizado =
                                              PrecioDeVentaProducto(
                                                  Moneda(value));
                                          setState(() {
                                            _controllerPrecioDeVenta.text =
                                                precioSanitizado.value
                                                    .toDouble()
                                                    .toString();
                                          });
                                          return null;
                                        } catch (e) {
                                          if (e is DomainEx) {
                                            return e.message;
                                          } else {
                                            return e.toString();
                                          }
                                        }
                                      }),
                                  ExTextField(
                                    fieldKey: _imagenURL,
                                    inputType: InputType.texto,
                                    hintText: 'Imagen URL',
                                    controller: _controllerImagen,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: (mostrarMargenLabel.resolve(context) ==
                                          true)
                                      ? Sizes.p40
                                      : 0,
                                ),
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      return ExBoton.primario(
                                          key: FormaProducto.btnGuardar,
                                          label: 'Guardar',
                                          icon: Iconos.edit,
                                          tamanoFuente: TextSizes.textSm,
                                          height: Sizes.p12,
                                          onTap: () async {
                                            if (await _guardarProducto()) {
                                              if (!mounted) return;
                                              // ScaffoldMessenger.of(context)
                                              //     .showSnackBar(const SnackBar(
                                              //   content: Text(
                                              //       'Producto creado exitosamente 🎉'),
                                              //   duration: Duration(seconds: 1),
                                              // ));

                                              ref
                                                  .read(providerListadoProductos
                                                      .notifier)
                                                  .obtenerProductos();

                                              // Si estamos en layout mobile nos regresamos
                                              if (context.breakpoint <=
                                                  LayoutBreakpoint.sm) {
                                                context.pop();
                                              }
                                            }
                                          });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: esDesktop.resolve(context) ? 5 : 0,
                                ),
                                esDesktop.resolve(context)
                                    ? SizedBox(
                                        width: Sizes.p40,
                                        height: Sizes.p12,
                                        child: ExBoton.secundario(
                                            label: 'Limpiar',
                                            icon: Iconos.delete,
                                            onTap: () {
                                              limpiarCampos();
                                            }),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class TituloForma extends StatelessWidget {
  const TituloForma({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final FormaProducto widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            top: Sizes.p2, left: Sizes.p40, bottom: Sizes.p4),
        child: Text(
          widget.titulo,
          style: const TextStyle(
              fontSize: TextSizes.text2xl,
              color: ColoresBase.neutral700,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.left,
        ));
  }
}
