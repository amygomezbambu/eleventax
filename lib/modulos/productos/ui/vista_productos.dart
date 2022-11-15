import 'package:eleventa/modulos/productos/ui/listado_productos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:layout/layout.dart';

class VistaProductos extends StatelessWidget {
  const VistaProductos({Key? key, required String title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      xs: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: ListadoProductos(),
          )
        ],
      ),
      md: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 180, top: 20),
            child: Text('Nuevo Producto',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: TailwindColors.blueGray[700])),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: ListadoProductos(),
          ),
        ],
      ),
    );
  }
}
