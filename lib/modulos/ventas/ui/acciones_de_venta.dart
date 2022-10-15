import 'package:flutter/material.dart';
import 'package:eleventa/modulos/ventas/ui/boton_accion_de_venta.dart';

class AccionesDeVenta extends StatelessWidget {
  const AccionesDeVenta({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: const [
              BotonAccionDeVenta('Aumentar', Icons.person),
              BotonAccionDeVenta('Disminuir', Icons.person)
            ],
          ),
          Row(
            children: const [
              BotonAccionDeVenta('Venta Rápida', Icons.person),
              BotonAccionDeVenta('Asignar Cliente', Icons.person)
            ],
          ),
          Row(
            children: const [
              BotonAccionDeVenta('Aplicar Descuento', Icons.person),
              BotonAccionDeVenta('Convertir a \n cotización', Icons.person)
            ],
          )
        ],
      ),
    );
  }
}
