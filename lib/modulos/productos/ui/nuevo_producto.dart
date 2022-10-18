import 'package:eleventa/modulos/common/ui/widgets/boton_primario.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:flutter/material.dart';

const List<String> listadoCategorias = <String>[
  'Refrescos',
  'Carnes',
  'Papeleria',
  'Enlatados'
];

const List<String> listaUnidadesDeMedida = <String>[
  'Pieza',
  'Kilogramo / Gramo',
  'Metro / Centimetro'
];

const List<String> listadoImpuestos = <String>[
  'IVA - 16%',
  'IVA - 8%',
  'IVA - 0%'
];

class NuevoProducto extends StatefulWidget {
  const NuevoProducto(BuildContext context, {Key? key}) : super(key: key);

  @override
  State<NuevoProducto> createState() => _NuevoProductoState();
}

enum SeVendePor { unidad, peso }

class _NuevoProductoState extends State<NuevoProducto> {
  String nombreCategoria = '';
  String unidadDeMedida = '';
  String impuesto = '';
  SeVendePor? seVendePor = SeVendePor.unidad;

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
                  const ExTextField(hintText: 'Codigo de producto'),
                  const ExTextField(hintText: 'Descripcion'),
                  DropdownButtonFormField<String>(
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
                  RadioListTile<SeVendePor>(
                      title: const Text('Unidad'),
                      value: SeVendePor.unidad,
                      groupValue: seVendePor,
                      onChanged: (SeVendePor? value) {
                        setState(() {
                          seVendePor = value;
                        });
                      }),
                  RadioListTile<SeVendePor>(
                      title: const Text('Peso'),
                      value: SeVendePor.peso,
                      groupValue: seVendePor,
                      onChanged: (SeVendePor? value) {
                        setState(() {
                          seVendePor = value;
                        });
                      }),
                  DropdownButtonFormField<String>(
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
                  DropdownButtonFormField<String>(
                    value: listadoImpuestos.first,
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        impuesto = value!;
                      });
                    },
                    items: listadoImpuestos
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const ExTextField(hintText: 'Precio de compra'),
                  const ExTextField(hintText: 'Utilidad'),
                  const ExTextField(hintText: 'Precio de venta'),
                  const ExTextField(hintText: 'Imagen URL'),
                ],
              ),
            ),
            BotonPrimario(
                label: 'Guardar',
                icon: Icons.save,
                onTap: () => {debugPrint('guardando')}),
            const SizedBox(
              height: 5,
            ),
            BotonPrimario(
                label: 'Cancelar',
                icon: Icons.cancel,
                onTap: () => {debugPrint('limpiando forma')})
          ],
        ),
      ),
    );
  }
}
