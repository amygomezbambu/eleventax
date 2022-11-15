import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/ui/listado_productos_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/domain/moneda.dart';
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
import 'package:eleventa/modulos/productos/ui/nuevo_producto_provider.dart';

class NuevoProducto extends ConsumerStatefulWidget {
  const NuevoProducto(BuildContext context, {Key? key}) : super(key: key);

  @override
  ConsumerState<NuevoProducto> createState() => _NuevoProductoState();
}

typedef EstadoFormField = FormFieldState<String>;

class _NuevoProductoState extends ConsumerState<NuevoProducto> {
  String unidadDeMedida = '';
  final mostrarMargenLabel = LayoutValue(xs: false, md: true);

  final FocusNode _focusNode = FocusNode();
  ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad;
  final _keyCategoria = GlobalKey<EstadoFormField>();
  final _keyImpuestos = GlobalKey<EstadoFormField>();
  final _keyUnidadDeMedida = GlobalKey<EstadoFormField>();
  final _formKey = GlobalKey<FormState>();

  final _codigoField = GlobalKey<FormFieldState<dynamic>>();
  final _nombreField = GlobalKey<FormFieldState<dynamic>>();
  final _precioCompraField = GlobalKey<FormFieldState<dynamic>>();
  final _precioVentaField = GlobalKey<FormFieldState<dynamic>>();

  late final Future<List<Impuesto>> _impuestos = lecturas.obtenerImpuestos();
  late Impuesto impuestoSeleccionado;

  late Categoria categoriaSeleccionada;
  late final Future<List<Categoria>> _categorias = lecturas.obtenerCategorias();

  late UnidadDeMedida unidadDeMedidaSeleccionada;
  late final Future<List<UnidadDeMedida>> _unidadesDeMedida =
      lecturas.obtenerUnidadesDeMedida();

  final _controllerCodigo = TextEditingController();
  final _controllerNombre = TextEditingController();
  final _controllerPrecioDeVenta = TextEditingController();
  final _controllerPrecioDeCompra = TextEditingController();
  final _controllerImagen = TextEditingController();
  final _controllerUtilidad = TextEditingController();

  var lecturas = ModuloProductos.repositorioConsultaProductos();

  void limpiarCampos() {
    _controllerCodigo.clear();
    _controllerImagen.clear();
    _controllerNombre.clear();
    _controllerPrecioDeCompra.clear();
    _controllerPrecioDeVenta.clear();
    _controllerUtilidad.clear();

    // _keyCategoria.currentState!.reset();
    // _keyImpuestos.currentState!.reset();
    // _keyUnidadDeMedida.currentState!.reset();

    seVendePor = ProductoSeVendePor.unidad;
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

  @override
  Widget build(BuildContext context) {
    var model = ref.read(nuevoProductoProvider.notifier);
    var state = ref.watch(nuevoProductoProvider);

    final notificadorListadoProductos =
        ref.read(providerListadoProductos.notifier);

    if (state is EstadoCargandoNuevoProducto) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(),
      );
    }

    if (state is EstadoExitoNuevoProducto) {}

    return Scaffold(
      body: Scrollbar(
        thumbVisibility: true,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
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
                                icon: state.existeCodigo
                                    ? Icons.error
                                    : Icons.document_scanner,
                                width: 300,
                                validator: (value) async {
                                  if (value == null) {
                                    return 'No se aceptan valores Nulos';
                                  }

                                  var resultadoValidacion = await model
                                      .sanitizarYValidarCodigo(value);

                                  if (resultadoValidacion == null) {
                                    _controllerCodigo.text =
                                        state.codigo != null
                                            ? state.codigo!.value
                                            : _controllerCodigo.text;
                                  }

                                  return resultadoValidacion;
                                }),
                            ExTextField(
                                fieldKey: _nombreField,
                                hintText: 'Nombre',
                                controller: _controllerNombre,
                                validator: (value) async {
                                  if (value == null) {
                                    return 'No se aceptan valores Nulos';
                                  }

                                  // TODO: Verificar si existe una mejor manera con Riverpod
                                  // y sus providers.
                                  var resultadoValidacion = await model
                                      .sanitizarYValidarNombre(value);

                                  if (resultadoValidacion == null) {
                                    _controllerNombre.text =
                                        state.nombre != null
                                            ? state.nombre!.value
                                            : _controllerNombre.text;
                                  }

                                  return resultadoValidacion;
                                }),
                            FutureBuilder<List<Categoria>>(
                                future: _categorias,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Categoria>> snapshot) {
                                  if (snapshot.hasData) {
                                    List<Categoria> listadoCategorias =
                                        snapshot.data!;
                                    if (UID.isValid(listadoCategorias.first.uid
                                        .toString())) {
                                      listadoCategorias.insert(
                                        0,
                                        Categoria(
                                          uid: UID.invalid(),
                                          nombre: 'Sin Categoria',
                                        ),
                                      );
                                    }

                                    state.categoria = listadoCategorias.first;

                                    return ExDropDown<Categoria>(
                                      hintText: 'Categoría',
                                      dropDownKey: _keyCategoria,
                                      value: state.categoria,
                                      onChanged: (Categoria? categoria) {
                                        state.categoria = categoria!;
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
                                onChange: (ProductoSeVendePor? seVendePor) {
                                  state.seVendePor = seVendePor!;
                                }),
                            ExRadioButton<ProductoSeVendePor>(
                                value: ProductoSeVendePor.peso,
                                groupValue: seVendePor,
                                label: 'Peso',
                                hint: '',
                                onChange: (ProductoSeVendePor? seVendePor) {
                                  state.seVendePor = seVendePor!;
                                }),

                            FutureBuilder<List<UnidadDeMedida>>(
                                future: _unidadesDeMedida,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<UnidadDeMedida>>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    List<UnidadDeMedida>
                                        listadoUnidadesDeMedida =
                                        snapshot.data!;
                                    state.unidadDeMedida =
                                        listadoUnidadesDeMedida.first;

                                    return ExDropDown<UnidadDeMedida>(
                                      hintText: 'Unidad de Medida',
                                      width: 300,
                                      dropDownKey: _keyUnidadDeMedida,
                                      value: listadoUnidadesDeMedida.first,
                                      onChanged:
                                          (UnidadDeMedida? unidadDeMedida) {
                                        state.unidadDeMedida = unidadDeMedida!;
                                      },
                                      items: listadoUnidadesDeMedida.map<
                                              DropdownMenuItem<UnidadDeMedida>>(
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
                                }),
                            FutureBuilder<List<Impuesto>>(
                                future: _impuestos,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Impuesto>> snapshot) {
                                  if (snapshot.hasData) {
                                    List<Impuesto> listadoImpuestos =
                                        snapshot.data!;

                                    state.impuesto = listadoImpuestos.first;

                                    return ExDropDown<Impuesto>(
                                      hintText: 'Impuesto',
                                      width: 170,
                                      dropDownKey: _keyImpuestos,
                                      value: listadoImpuestos.first,
                                      onChanged: (Impuesto? impuesto) {
                                        state.impuesto = impuesto!;
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
                                  PrecioDeCompraProducto(Moneda(value));
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
                                    PrecioDeVentaProducto(Moneda(value));
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
                            child: ExBotonPrimario(
                                label: 'Guardar',
                                icon: Icons.save,
                                tamanoFuente: 15,
                                onTap: () async {
                                  await model.crearProducto();
                                  // Nos aseguramos que el widget aun exista
                                  // antes de mostrar el snackBar
                                  if (!mounted) return;
                                  limpiarCampos();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Producto creado exitosamente 🎉'),
                                    duration: Duration(seconds: 3),
                                  ));

                                  // Mandamos refrescar el provider de listado de productos
                                  notificadorListadoProductos
                                      .obtenerProductos();
                                }),
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
                                  model.limpiar();
                                }),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
