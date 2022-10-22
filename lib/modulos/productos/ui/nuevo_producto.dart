import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
//import 'package:layout/layout.dart';

class NuevoProducto extends StatefulWidget {
  const NuevoProducto(BuildContext context, {Key? key}) : super(key: key);

  @override
  State<NuevoProducto> createState() => _NuevoProductoState();
}

typedef EstadoFormField = FormFieldState<String>;

class _NuevoProductoState extends State<NuevoProducto> {
  String unidadDeMedida = '';
  final mostrarMargenLabel = LayoutValue(xs: false, md: true);

  ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad;
  final GlobalKey<EstadoFormField> _keyCategoria = GlobalKey<EstadoFormField>();
  final GlobalKey<EstadoFormField> _keyImpuestos = GlobalKey<EstadoFormField>();
  final GlobalKey<EstadoFormField> _keyUnidadDeMedida =
      GlobalKey<EstadoFormField>();

  late Impuesto impuestoSeleccionado;
  late final Future<List<Impuesto>> _impuestos = lecturas.obtenerImpuestos();

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
    var producto = Producto.crear(
        codigo: _controllerCodigo.text,
        nombre: _controllerNombre.text,
        precioDeVenta: Moneda.fromDoubleString(_controllerPrecioDeVenta.text),
        precioDeCompra: Moneda.fromDoubleString(_controllerPrecioDeCompra.text),
        seVendePor: seVendePor,
        categoria: categoriaSeleccionada,
        impuestos: [impuestoSeleccionado],
        unidadDeMedida: unidadDeMedidaSeleccionada);

    crearProducto.req.producto = producto;

    await crearProducto.exec();

    setState(() {
      limpiarCampos();
    });
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

  @override
  void dispose() {
    _controllerCodigo.dispose();
    _controllerNombre.dispose();
    _controllerPrecioDeCompra.dispose();
    _controllerPrecioDeVenta.dispose();
    _controllerImagen.dispose();
    _controllerUtilidad.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white10,
        width: 600,
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
                  ),
                  ExTextField(
                    hintText: 'Nombre',
                    controller: _controllerNombre,
                  ),
                  FutureBuilder<List<Categoria>>(
                      future: _categorias,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Categoria>> snapshot) {
                        if (snapshot.hasData) {
                          List<Categoria> listadoCategorias = snapshot.data!;
                          return DropdownButtonFormField<Categoria>(
                            key: _keyCategoria,
                            value: listadoCategorias.first,
                            onChanged: (Categoria? categoria) {
                              // This is called when the user selects an item.
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
                  RadioListTile<ProductoSeVendePor>(
                      title: const Text('Unidad'),
                      value: ProductoSeVendePor.unidad,
                      toggleable: true,
                      groupValue: seVendePor,
                      onChanged: (ProductoSeVendePor? value) {
                        setState(() {
                          seVendePor = value!;
                        });
                      }),
                  RadioListTile<ProductoSeVendePor>(
                      title: const Text('Peso'),
                      value: ProductoSeVendePor.peso,
                      groupValue: seVendePor,
                      toggleable: true,
                      onChanged: (ProductoSeVendePor? value) {
                        setState(() {
                          seVendePor = value!;
                        });
                      }),
                  FutureBuilder<List<UnidadDeMedida>>(
                      future: _unidadesDeMedida,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<UnidadDeMedida>> snapshot) {
                        if (snapshot.hasData) {
                          List<UnidadDeMedida> listadoUnidadesDeMedida =
                              snapshot.data!;
                          return DropdownButtonFormField<UnidadDeMedida>(
                            key: _keyUnidadDeMedida,
                            value: listadoUnidadesDeMedida.first,
                            onChanged: (UnidadDeMedida? unidadDeMedida) {
                              // This is called when the user selects an item.
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
                          return DropdownButtonFormField<Impuesto>(
                            key: _keyImpuestos,
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
                  ExTextField(
                    hintText: 'Precio de compra',
                    controller: _controllerPrecioDeCompra,
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
    );
  }
}
