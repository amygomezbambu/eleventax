import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_drop_down.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_numeric_field.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_radio_button.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:layout/layout.dart';

class NuevoProducto extends StatefulWidget {
  const NuevoProducto(BuildContext context, {Key? key}) : super(key: key);

  @override
  State<NuevoProducto> createState() => _NuevoProductoState();
}

typedef EstadoFormField = FormFieldState<String>;

class _NuevoProductoState extends State<NuevoProducto> {
  String unidadDeMedida = '';
  final mostrarMargenLabel = LayoutValue(xs: false, md: true);

  final FocusNode _focusNode = FocusNode();
  ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad;
  final GlobalKey<EstadoFormField> _keyCategoria = GlobalKey<EstadoFormField>();
  final GlobalKey<EstadoFormField> _keyImpuestos = GlobalKey<EstadoFormField>();
  final GlobalKey<EstadoFormField> _keyUnidadDeMedida =
      GlobalKey<EstadoFormField>();

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

  Future<void> crearProducto() async {
    var crearProducto = ModuloProductos.crearProducto();
    bool hayPrecioDeVenta = _controllerPrecioDeVenta.text.isNotEmpty;
    PrecioDeVentaProducto? precioDeVenta;

    if (hayPrecioDeVenta) {
      precioDeVenta =
          PrecioDeVentaProducto(Moneda(_controllerPrecioDeVenta.text));
    }

    try {
      var producto = Producto.crear(
        codigo: CodigoProducto(_controllerCodigo.text),
        nombre: NombreProducto(_controllerNombre.text),
        precioDeCompra:
            PrecioDeCompraProducto(Moneda(_controllerPrecioDeCompra.text)),
        seVendePor: seVendePor,
        categoria: categoriaSeleccionada,
        impuestos: [impuestoSeleccionado],
        unidadDeMedida: unidadDeMedidaSeleccionada,
        preguntarPrecio: !hayPrecioDeVenta,
        precioDeVenta: precioDeVenta,
      );

      crearProducto.req.producto = producto;

      await crearProducto.exec();

      setState(() {
        limpiarCampos();
      });
    } catch (e) {
      debugPrint('No fue posible crear producto: $e');
    }
  }

  void limpiarCampos() {
    _controllerCodigo.clear();
    _controllerImagen.clear();
    _controllerNombre.clear();
    _controllerPrecioDeCompra.clear();
    _controllerPrecioDeVenta.clear();
    _controllerUtilidad.clear();

    _keyCategoria.currentState!.reset();
    _keyImpuestos.currentState!.reset();
    _keyUnidadDeMedida.currentState!.reset();

    seVendePor = ProductoSeVendePor.unidad;
  }

  Future<void> verificarExistenciaDeCodigo() async {
    var consultas = ModuloProductos.repositorioConsultaProductos();

    var existe = await consultas.existeProducto(_controllerCodigo.text);

    if (existe) {
      // TODO: UI manejar esta advertencia
      debugPrint(
          'El codigo ${_controllerCodigo.text} ya existe en base de datos...');
    }
  }

  Future<void> sanitizarYValidarCodigo() async {
    try {
      _controllerCodigo.text = CodigoProducto(_controllerCodigo.text).value;
      await verificarExistenciaDeCodigo();
    } catch (e) {
      // TODO: UI manejar esta advertencia
      debugPrint(
          'El codigo ${_controllerCodigo.text} no es valido para su registro');
    }
  }

  Future<void> sanitizarYValidarNombre() async {
    try {
      _controllerNombre.text = NombreProducto(_controllerNombre.text).value;
    } catch (e) {
      // TODO: UI manejar esta advertencia
      debugPrint('El nombre no es valido');
    }
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
    return Container(
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
                key: const ValueKey('frmNuevoProducto'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExTextField(
                      hintText: 'Código',
                      controller: _controllerCodigo,
                      icon: Icons.document_scanner,
                      width: 300,
                      onExit: () async {
                        await sanitizarYValidarCodigo();
                      },
                    ),
                    ExTextField(
                      hintText: 'Nombre',
                      controller: _controllerNombre,
                      onExit: () async {
                        await sanitizarYValidarNombre();
                      },
                    ),
                    FutureBuilder<List<Categoria>>(
                        future: _categorias,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Categoria>> snapshot) {
                          if (snapshot.hasData) {
                            List<Categoria> listadoCategorias = snapshot.data!;

                            if (!listadoCategorias.first.uid.isInvalid()) {
                              listadoCategorias.insert(
                                0,
                                Categoria(
                                  uid: UID.invalid(),
                                  nombre: 'Sin Categoria',
                                ),
                              );
                              categoriaSeleccionada = listadoCategorias.first;
                            }

                            return ExDropDown<Categoria>(
                              hintText: 'Categoría',
                              dropDownKey: _keyCategoria,
                              value: categoriaSeleccionada,
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
                    // RadioListTile<ProductoSeVendePor>(

                    FutureBuilder<List<UnidadDeMedida>>(
                        future: _unidadesDeMedida,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<UnidadDeMedida>> snapshot) {
                          if (snapshot.hasData) {
                            List<UnidadDeMedida> listadoUnidadesDeMedida =
                                snapshot.data!;
                            unidadDeMedidaSeleccionada =
                                listadoUnidadesDeMedida.first;
                            return ExDropDown<UnidadDeMedida>(
                              hintText: 'Unidad de Medida',
                              width: 300,
                              dropDownKey: _keyUnidadDeMedida,
                              value: listadoUnidadesDeMedida.first,
                              onChanged: (UnidadDeMedida? unidadDeMedida) {
                                setState(() {
                                  unidadDeMedidaSeleccionada = unidadDeMedida!;
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
                        }),
                    FutureBuilder<List<Impuesto>>(
                        future: _impuestos,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Impuesto>> snapshot) {
                          if (snapshot.hasData) {
                            List<Impuesto> listadoImpuestos = snapshot.data!;
                            impuestoSeleccionado = listadoImpuestos.first;

                            return ExDropDown<Impuesto>(
                              hintText: 'Impuesto',
                              width: 160,
                              dropDownKey: _keyImpuestos,
                              value: listadoImpuestos.first,
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
                    ExNumericField(
                      hintText: 'Precio de compra',
                      controller: _controllerPrecioDeCompra,
                      helperText: 'Con Impuestos',
                      prefixText: '\$ ',
                      width: 160,
                      
                    ),
                    ExTextField(
                        hintText: 'Utilidad',
                        controller: _controllerUtilidad,
                        suffixText: '%',
                        width: 160),
                    ExTextField(
                      hintText: 'Precio de venta',
                      controller: _controllerPrecioDeVenta,
                      prefixText: '\$ ',
                      width: 160,
                    ),
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
                    width:
                        (mostrarMargenLabel.resolve(context) == true) ? 160 : 0,
                  ),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ExBotonPrimario(
                        label: 'Guardar',
                        icon: Icons.save,
                        tamanoFuente: 15,
                        onTap: () async {
                          await crearProducto();
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
                        onTap: () => {limpiarCampos()}),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}