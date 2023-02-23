import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:eleventa/modulos/config/ui/configuraciones.dart';
import 'package:eleventa/modulos/config/ui/vista_configuracion_modulo.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class VistaConfiguracion extends StatefulWidget {
  const VistaConfiguracion({super.key});

  @override
  State<VistaConfiguracion> createState() => _VistaConfiguracionState();
}

class _VistaConfiguracionState extends State<VistaConfiguracion> {
  final esDesktop = LayoutValue(xs: false, md: true);
  int _indiceSeleccionado = 0;
  late Widget widgetViewSeleccionado;
  String? labelConfiguracionActual;

  @override
  initState() {
    super.initState();
    widgetViewSeleccionado = const Text('Selecciona una opcion');
  }

  @override
  Widget build(BuildContext context) {
    var items = <ListItem>[];
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

    return Scaffold(
      appBar: !esDesktop.resolve(context)
          ? const ExAppBar(
              titleText: 'Configuración',
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: esDesktop.resolve(context)
                ? Sizes.p64
                : MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  width: 1,
                  color: ColoresBase.neutral200,
                ),
              ),
              color: ColoresBase.neutral100,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.all(Sizes.p2),
                child: ListView.separated(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return ListTile(
                        title: item.buildTitle(context,
                            seleccionado: (index == _indiceSeleccionado)),
                        hoverColor: ColoresBase.neutral200,
                        dense: true,
                        leading: item.buildLeading(context,
                            selecciondo: (index == _indiceSeleccionado)),
                        visualDensity: VisualDensity.comfortable,
                        tileColor: (item is OpcionConfiguracionItem) &&
                                (!esDesktop.resolve(context))
                            ? ColoresBase.neutral200
                            : null,
                        minLeadingWidth: 5,
                        horizontalTitleGap: 10,
                        trailing: (item is OpcionConfiguracionItem) &&
                                (!esDesktop.resolve(context))
                            ? const Icon(
                                Icons.chevron_right,
                                color: ColoresBase.neutral400,
                              )
                            : null,
                        selected: (index == _indiceSeleccionado) &&
                            esDesktop.resolve(context),
                        selectedTileColor: ColoresBase.neutral200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.p2),
                        ),
                        onTap: item is OpcionConfiguracionItem
                            ? () {
                                // En modo desktop mostramos el widget en la columna de la derecha
                                if (esDesktop.resolve(context)) {
                                  setState(() {
                                    _indiceSeleccionado = index;
                                    labelConfiguracionActual = item.label;
                                    widgetViewSeleccionado =
                                        item.buildChildView(context);
                                  });
                                } else {
                                  // En mobile mostramos el widget de config en una nueva vista
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: ExAppBar(
                                          titleText: item.label,
                                        ),
                                        body: VistaConfiguracionModulo(
                                            child:
                                                item.buildChildView(context)),
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                          height: Sizes.p1,
                        )),
              ),
            ),
          ),
          // En desktop mostramos el panel a la derecha, en mobile nada
          esDesktop.resolve(context)
              ? Expanded(
                  child: VistaConfiguracionModulo(
                    titulo: labelConfiguracionActual,
                    child: widgetViewSeleccionado,
                  ),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
    );
  }
}

abstract class ListItem {
  Widget buildTitle(BuildContext context, {bool seleccionado = false});

  Widget? buildSubtitle(BuildContext context);

  Widget? buildLeading(BuildContext context, {bool selecciondo = false});

  Widget buildChildView(BuildContext context);
}

/// A ListItem that contains data to display a heading.
class EncabezadoItem implements ListItem {
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
  Widget? buildSubtitle(BuildContext context) => null;

  @override
  Widget? buildLeading(BuildContext context, {bool selecciondo = false}) =>
      null;

  @override
  Widget buildChildView(BuildContext context, {bool selecciondo = false}) =>
      const Spacer();
}

/// A ListItem that contains data to display a message.
class OpcionConfiguracionItem implements ListItem {
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
  Widget? buildSubtitle(BuildContext context) => null;

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
}
