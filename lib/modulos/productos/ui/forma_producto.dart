import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
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
  final Producto? producto;

  const FormaProducto(
    BuildContext context, {
    Key? key,
    this.producto,
  }) : super(key: key);

  @override
  State<FormaProducto> createState() => _FormaProductoState();
}

typedef EstadoFormField = FormFieldState<String>;

class _FormaProductoState extends State<FormaProducto> {
  final mostrarMargenLabel = LayoutValue(xs: false, md: true);

  final FocusNode _focusNode = FocusNode();
  final _keyCategoria = GlobalKey<EstadoFormField>();
  final _keyImpuestos = GlobalKey<EstadoFormField>();
  final _keyUnidadDeMedida = GlobalKey<EstadoFormField>();
  final _formKey = GlobalKey<FormState>();

  final _codigoField = GlobalKey<FormFieldState<dynamic>>();
  final _nombreField = GlobalKey<FormFieldState<dynamic>>();
  final _precioCompraField = GlobalKey<FormFieldState<dynamic>>();
  final _precioVentaField = GlobalKey<FormFieldState<dynamic>>();
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

  var lecturas = ModuloProductos.repositorioConsultaProductos();

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

    // TODO: Establecer foco otra vez en codigo
    //FocusScope.of(context).requestFocus(FocusNode());
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

    super.dispose();
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
    _cargarProducto();
  }

  @override
  void didUpdateWidget(FormaProducto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.producto != oldWidget.producto) {
      _cargarProducto();
      // TODO: Resetear validaciones para que cuando se cambie de producto
      // no aparezca error de codigo existente
    }
  }

  Future<bool> _verificarExistenciaDeCodigo(String codigo) async {
    var consultas = ModuloProductos.repositorioConsultaProductos();

    if (widget.producto == null) {
      return await consultas.existeProducto(codigo);
    } else {
      if (widget.producto!.codigo != codigo) {
        return await consultas.existeProducto(codigo);
      }
    }

    return false;
  }

  Future<bool> _guardarProducto() async {
    if (widget.producto == null) {
      await _crearProducto();
    } else {
      await _modificarProducto();
    }

    return true;
  }

  Future<void> _modificarProducto() async {
    var modificarProducto = ModuloProductos.modificarProducto();

    var producto = _llenarProducto();

    producto = producto.copyWith(uid: widget.producto!.uid);

    modificarProducto.req.producto = producto;
    try {
      await modificarProducto.exec();
    } catch (e) {
      //TODO: mostrar alerta visual con el error
      debugPrint(e.toString());
    }
  }

  Future<void> _crearProducto() async {
    var crearProducto = ModuloProductos.crearProducto();

    try {
      Producto productoNuevo = _llenarProducto();

      crearProducto.req.producto = productoNuevo;

      await crearProducto.exec();

      setState(() {
        limpiarCampos();
      });

      //
    } catch (e) {
      debugPrint('No fue posible crear producto: $e');
    }
  }

  Producto _llenarProducto() {
    bool hayPrecioDeVenta = _controllerPrecioDeVenta.text.isNotEmpty;
    PrecioDeVentaProducto? precioDeVenta;

    if (hayPrecioDeVenta) {
      precioDeVenta =
          PrecioDeVentaProducto(Moneda(_controllerPrecioDeVenta.text));
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

  void _cargarProducto() {
    // Reiniciamos el estado de validacion de los campos
    if (_codigoField.currentState != null) {
      _codigoField.currentState!.reset();
      _nombreField.currentState!.reset();
      _precioCompraField.currentState!.reset();
      _precioVentaField.currentState!.reset();
      _imagenURL.currentState!.reset();
    }

    if (widget.producto != null) {
      _controllerCodigo.text = widget.producto!.codigo;

      _controllerNombre.text = widget.producto!.nombre;
      _controllerPrecioDeCompra.text =
          widget.producto!.precioDeCompra.toDouble().toString();
      if (widget.producto!.precioDeVenta != null) {
        _controllerPrecioDeVenta.text =
            widget.producto!.precioDeVenta!.toDouble().toString();
      }
      _controllerImagen.text = widget.producto!.imagenURL;

      categoriaSeleccionada = widget.producto!.categoria;
      unidadDeMedidaSeleccionada = widget.producto!.unidadMedida;

      if (widget.producto!.impuestos.isNotEmpty) {
        impuestoSeleccionado = widget.producto!.impuestos.first;
      }

      seVendePor = widget.producto!.seVendePor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          primary: true,
          scrollDirection: Axis.vertical,
          child: Container(
            color: Colors.white10,
            width: 600,
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
                          ExTextField(
                              fieldKey: _codigoField,
                              hintText: 'Código',
                              controller: _controllerCodigo,
                              icon: Icons.document_scanner,

                              // icon: state.existeCodigo
                              //     ? Icons.error
                              //     : Icons.document_scanner,
                              width: 300,
                              validator: (value) async {
                                if (value == null) {
                                  return 'No se aceptan valores Nulos';
                                }

                                try {
                                  var codigoSanitizado = CodigoProducto(value);

                                  setState(() {
                                    debugPrint(
                                        'estableciendo código a: ${codigoSanitizado.value}');
                                    _controllerCodigo.text =
                                        codigoSanitizado.value;
                                  });

                                  var existeCodigo =
                                      await _verificarExistenciaDeCodigo(
                                          codigoSanitizado.value);

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
                              }),
                          ExTextField(
                              fieldKey: _nombreField,
                              hintText: 'Nombre',
                              controller: _controllerNombre,
                              validator: (value) async {
                                if (value == null) {
                                  return 'No se aceptan valores vacios';
                                }

                                try {
                                  var nombreSanitizado = NombreProducto(value);

                                  setState(() {
                                    _controllerNombre.text =
                                        nombreSanitizado.value;
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
                          FutureBuilder<List<Categoria>>(
                              future: _categorias,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Categoria>> snapshot) {
                                if (snapshot.hasData) {
                                  List<Categoria> listadoCategorias =
                                      snapshot.data!;
                                  if (UID.isValid(
                                      listadoCategorias.first.uid.toString())) {
                                    listadoCategorias.insert(
                                      0,
                                      _obtenerSinCategoria(),
                                    );
                                  }

                                  categoriaSeleccionada ??=
                                      listadoCategorias.first;

                                  return ExDropDown<Categoria>(
                                    hintText: 'Categoría',
                                    dropDownKey: _keyCategoria,
                                    value: categoriaSeleccionada!,
                                    onChanged: (Categoria? categoria) {
                                      setState(() {
                                        categoriaSeleccionada = categoria!;
                                      });
                                    },
                                    items: listadoCategorias
                                        .map<DropdownMenuItem<Categoria>>(
                                            (Categoria value) {
                                      return DropdownMenuItem<Categoria>(
                                        value: value,
                                        child: Text(value.nombre),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }),
                          ExRadioButton<ProductoSeVendePor>(
                              value: ProductoSeVendePor.unidad,
                              groupValue: seVendePor,
                              label: 'Unidad',
                              hint: 'Se vende por',
                              onChange: (ProductoSeVendePor? value) {
                                setState(() {
                                  seVendePor = value!;
                                });
                              }),
                          ExRadioButton<ProductoSeVendePor>(
                              value: ProductoSeVendePor.peso,
                              groupValue: seVendePor,
                              label: 'Peso',
                              hint: '',
                              onChange: (ProductoSeVendePor? value) {
                                setState(() {
                                  seVendePor = value!;
                                });
                              }),

                          FutureBuilder<List<UnidadDeMedida>>(
                              future: _unidadesDeMedida,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<UnidadDeMedida>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  List<UnidadDeMedida> listadoUnidadesDeMedida =
                                      snapshot.data!;

                                  unidadDeMedidaSeleccionada ??=
                                      listadoUnidadesDeMedida.first;

                                  return ExDropDown<UnidadDeMedida>(
                                    hintText: 'Unidad de Medida',
                                    width: 300,
                                    dropDownKey: _keyUnidadDeMedida,
                                    value: unidadDeMedidaSeleccionada!,
                                    onChanged:
                                        (UnidadDeMedida? unidadDeMedida) {
                                      setState(() {
                                        unidadDeMedidaSeleccionada =
                                            unidadDeMedida!;
                                        debugPrint(
                                            'nueva undiad de medida: ${unidadDeMedidaSeleccionada?.nombre}');
                                      });
                                    },
                                    items: listadoUnidadesDeMedida
                                        .map<DropdownMenuItem<UnidadDeMedida>>(
                                            (UnidadDeMedida value) {
                                      return DropdownMenuItem<UnidadDeMedida>(
                                        value: value,
                                        child: Text(value.nombre),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }), //loaading, //ya termine
                          FutureBuilder<List<Impuesto>>(
                              future: _impuestos,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Impuesto>> snapshot) {
                                if (snapshot.hasData) {
                                  List<Impuesto> listadoImpuestos =
                                      snapshot.data!;
                                  impuestoSeleccionado ??=
                                      listadoImpuestos.first;

                                  return ExDropDown<Impuesto>(
                                    hintText: 'Impuesto',
                                    width: 160,
                                    dropDownKey: _keyImpuestos,
                                    value: impuestoSeleccionado!,
                                    onChanged: (Impuesto? impuesto) {
                                      setState(() {
                                        impuestoSeleccionado = impuesto!;
                                      });
                                    },
                                    items: listadoImpuestos
                                        .map<DropdownMenuItem<Impuesto>>(
                                            (Impuesto value) {
                                      return DropdownMenuItem<Impuesto>(
                                        value: value,
                                        child: Text(value.nombre),
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              }),
                          ExTextField(
                            fieldKey: _precioCompraField,
                            hintText: 'Precio de compra',
                            controller: _controllerPrecioDeCompra,
                            helperText: 'Con Impuestos',
                            prefixText: '\$ ',
                            width: 170,
                            inputType: InputType.numerico,
                            validator: (value) async {
                              if (value == null || value.isEmpty) {
                                return 'No puede estar vacio';
                              }

                              try {
                                var precioSanitizado =
                                    PrecioDeCompraProducto(Moneda(value));
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
                              fieldKey: _precioVentaField,
                              hintText: 'Precio de venta',
                              controller: _controllerPrecioDeVenta,
                              prefixText: '\$ ',
                              width: 170,
                              inputType: InputType.numerico,
                              validator: (value) async {
                                if (value == null || value.isEmpty) {
                                  return 'No puede estar vacio';
                                }

                                try {
                                  var precioSanitizado =
                                      PrecioDeVentaProducto(Moneda(value));
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
                          width: (mostrarMargenLabel.resolve(context) == true)
                              ? 160
                              : 0,
                        ),
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: Consumer(
                            builder: (context, ref, child) {
                              return ExBotonPrimario(
                                  label: 'Guardar',
                                  icon: Icons.save,
                                  tamanoFuente: 15,
                                  onTap: () async {
                                    if (await _guardarProducto()) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Producto creado exitosamente 🎉'),
                                        duration: Duration(seconds: 3),
                                      ));
                                    }

                                    ref
                                        .read(providerListadoProductos.notifier)
                                        .obtenerProductos();
                                  });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        SizedBox(
                          width: 150,
                          height: 45,
                          child: ExBotonPrimario(
                              label: 'Cancelar',
                              tamanoFuente: 15,
                              icon: Icons.cancel,
                              onTap: () {
                                limpiarCampos();
                              }),
                        ),
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
}
