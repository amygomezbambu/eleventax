import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_maestro_detalle.dart';
import 'package:eleventa/modulos/config/ui/configuraciones.dart';
import 'package:flutter/material.dart';

class VistaConfiguracion extends StatelessWidget {
  const VistaConfiguracion({super.key});

  @override
  Widget build(BuildContext context) {
    var items = <ListadoResponsivoItem>[];
    for (var element in configuracion) {
      items.add(EncabezadoItem(element.nombre));
      for (var element in element.configuraciones) {
        items.add(OpcionConfiguracionItem(
          label: element.nombre,
          icon: element.icono,
          child: element.vista,
        ));
      }
    }

    return ExVistaMaestroDetalle(
      title: 'Configuración',
      factorAnchoDesktop: 0.8,
      items: items,
      // Seleccionamos el segundo elemento ya que el primero es el encabezado
      indiceItemSeleccionInicial: 1,
    );
  }
}

class EncabezadoItem extends ListadoResponsivoItem {
  final String heading;

  EncabezadoItem(this.heading);

  @override
  Widget buildTitle(BuildContext context, {bool seleccionado = false}) {
    return Text(heading,
        style: const TextStyle(
          fontSize: 16,
          color: ColoresBase.neutral900,
        ));
  }

  @override
  bool esSeleccionable() {
    return false;
  }
}

class OpcionConfiguracionItem extends ListadoResponsivoItem {
  final String label;
  final IconData icon;
  final Widget child;

  OpcionConfiguracionItem({
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
  Widget? buildLeading(BuildContext context, {bool selecciondo = false}) {
    return Icon(
      icon,
      size: 16,
      color: selecciondo ? Colores.accionPrimaria : ColoresBase.neutral700,
    );
  }

  @override
  Widget buildChildView(BuildContext context) {
    return child;
  }

  @override
  String tituloVentana() {
    return label;
  }
}
