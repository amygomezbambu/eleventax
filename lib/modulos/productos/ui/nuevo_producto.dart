import 'package:eleventa/modulos/common/ui/widgets/boton_primario.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter/material.dart';

const List<String> listaUnidadesDeMedida = <String>[
  'Pieza',
  'Kilogramo / Gramo',
  'Metro / Centimetro'
];

const List<String> listadoCategorias = <String>[
  'Refrescos',
  'Carnes',
  'Papeleria',
  'Enlatados'
];

class NuevoProducto extends StatefulWidget {
  const NuevoProducto(BuildContext context, {Key? key}) : super(key: key);

  @override
  State<NuevoProducto> createState() => _NuevoProductoState();
}

typedef EstadoFormField = FormFieldState<String>;

class _NuevoProductoState extends State<NuevoProducto> {
  String nombreCategoria = '';
  String unidadDeMedida = '';
  String impuesto = '';
  ProductoSeVendePor seVendePor = ProductoSeVendePor.unidad;
  final GlobalKey<EstadoFormField> _keyCategoria = GlobalKey<EstadoFormField>();
  final GlobalKey<EstadoFormField> _keyImpuestos = GlobalKey<EstadoFormField>();
  final GlobalKey<EstadoFormField> _keyUnidadDeMedida =
      GlobalKey<EstadoFormField>();

  final _controllerCodigo = TextEditingController();
  final _controllerNombre = TextEditingController();
  final _controllerPrecioDeVenta = TextEditingController();
  final _controllerPrecioDeCompra = TextEditingController();
  final _controllerImagen = TextEditingController();
  final _controllerUtilidad = TextEditingController();

  var lecturas = ModuloProductos.repositorioLecturaProductos();

  Future<void> crearProducto() async {
    var crearProducto = ModuloProductos.crearProducto();
    var producto = Producto.crear(
        codigo: _controllerCodigo.text,
        nombre: _controllerNombre.text,
        precioDeVenta: int.parse(_controllerPrecioDeVenta.text),
        precioDeCompra: int.parse(_controllerPrecioDeVenta.text),
        seVendePor: seVendePor,
        categoria: nombreCategoria,
        unidadDeMedida: UnidadDeMedida(
          uid: UID(),
          nombre: 'Pieza',
          abreviacion: 'pz',
        ));

    crearProducto.req.producto = producto;

    await crearProducto.exec();

    // Ya se creo, limpiamos la forma
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
    nombreCategoria = listadoCategorias.first;
    //impuesto = listadoImpuestos.first;
    unidadDeMedida = listaUnidadesDeMedida.first;
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
        width: 400,
        child: Column(
          children: [
            const Text('Nuevo Producto'),
            Form(
              key: const ValueKey('frmNuevoProducto'),
              child: Column(
                children: [
                  ExTextField(
                    hintText: 'Codigo de producto',
                    controller: _controllerCodigo,
                  ),
                  ExTextField(
                    hintText: 'Nombre',
                    controller: _controllerNombre,
                  ),
                  DropdownButtonFormField<String>(
                    key: _keyCategoria,
                    value: listadoCategorias.first,
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        nombreCategoria = value!;
                        //dropdownValue = value!;
                      });
                    },
                    items: listadoCategorias
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
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
                  DropdownButtonFormField<String>(
                    key: _keyUnidadDeMedida,
                    value: listaUnidadesDeMedida.first,
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        unidadDeMedida = value!;
                      });
                    },
                    items: listaUnidadesDeMedida
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  FutureBuilder<List<Impuesto>>(
                      future: lecturas.obtenerImpuestos(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Impuesto>> snapshot) {
                        if (snapshot.hasData) {
                          List<Impuesto> listadoImpuestos = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            key: _keyImpuestos,
                            value: listadoImpuestos.first.nombre,
                            onChanged: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                // TODO: Evitar que se mande llamar el future cada vez que cambiamos la seleccion
                                impuesto = value!;
                              });
                            },
                            items: listadoImpuestos
                                .map<DropdownMenuItem<String>>(
                                    (Impuesto value) {
                              return DropdownMenuItem<String>(
                                value: value.nombre,
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
                      controller: _controllerPrecioDeCompra),
                  ExTextField(
                    hintText: 'Utilidad',
                    controller: _controllerUtilidad,
                  ),
                  ExTextField(
                    hintText: 'Precio de venta',
                    controller: _controllerPrecioDeVenta,
                  ),
                  ExTextField(
                    hintText: 'Imagen URL',
                    controller: _controllerImagen,
                  ),
                ],
              ),
            ),
            BotonPrimario(
                label: 'Guardar',
                icon: Icons.save,
                onTap: () async {
                  await crearProducto();
                }),
            const SizedBox(
              height: 5,
            ),
            BotonPrimario(
                label: 'Cancelar',
                icon: Icons.cancel,
                onTap: () => {limpiarCampos()})
          ],
        ),
      ),
    );
  }
}
