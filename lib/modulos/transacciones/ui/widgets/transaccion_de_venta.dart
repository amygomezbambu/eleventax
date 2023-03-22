import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/vista_maestro_detalle_responsiva.dart';
import 'package:flutter/material.dart';

class TransaccionDeVenta implements ListadoItem {
  final String label;
  final IconData icon;
  final Widget child;

  TransaccionDeVenta({
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget buildTitle(BuildContext context, {bool seleccionado = false}) =>
      Text(label,
          style: TextStyle(
            fontSize: 13,
            color:
                seleccionado ? Colores.accionPrimaria : ColoresBase.neutral700,
          ));

  @override
  Widget buildChildView(BuildContext context) {
    return child;
  }
}
