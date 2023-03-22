import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class VistaMeaestroDetalleResponsiva extends StatefulWidget {
  final String titulo;
  final List<ListadoItem> items;

  const VistaMeaestroDetalleResponsiva(
      {super.key, required this.items, required this.titulo});

  @override
  State<VistaMeaestroDetalleResponsiva> createState() =>
      _VistaMeaestroDetalleResponsivaState();
}

class _VistaMeaestroDetalleResponsivaState
    extends State<VistaMeaestroDetalleResponsiva> {
  final esDesktop = LayoutValue(xs: false, md: true);
  int _indiceSeleccionado = 1;
  Widget? widgetViewSeleccionado;
  String? labelConfiguracionActual;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !esDesktop.resolve(context)
          ? ExAppBar(
              titleText: widget.titulo,
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
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return ListTile(
                          title: item.buildTitle(context),
                          hoverColor: ColoresBase.neutral200,
                          dense: true,
                          leading: const Icon(Icons.money),
                          visualDensity: VisualDensity.comfortable,
                          minLeadingWidth: 5,
                          horizontalTitleGap: 10,
                          trailing: const Text('12.50'),
                          selectedTileColor: ColoresBase.neutral200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Sizes.p2),
                          ),
                          onTap: () {
                            print('Seleccionado item $index');
                            // En modo desktop mostramos el widget en la columna de la derecha
                            if (esDesktop.resolve(context)) {
                              setState(() {
                                _indiceSeleccionado = index;
                                labelConfiguracionActual = index.toString();
                                widgetViewSeleccionado =
                                    item.buildChildView(context);
                              });
                            } else {
                              // En mobile mostramos el widget de config en una nueva vista
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: ExAppBar(
                                      titleText: item.toString(),
                                    ),
                                    body: VistaDetalle(
                                        child: item.buildChildView(context)),
                                  ),
                                ),
                              );
                            }
                          });
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
                  child: VistaDetalle(
                    titulo: 'Test',
                    child:
                        widgetViewSeleccionado ?? const Text('selecciona algo'),
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

abstract class ListadoItem {
  Widget buildTitle(BuildContext context, {bool seleccionado = false});

  // Widget? buildSubtitle(BuildContext context);

  // Widget? buildLeading(BuildContext context, {bool selecciondo = false});

  Widget buildChildView(BuildContext context);
}

class VistaDetalle extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String? titulo;
  final Widget child;

  VistaDetalle({
    super.key,
    required this.child,
    this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    final paddingContenedor = esDesktop.resolve(context) ? Sizes.p10 : Sizes.p4;

    return Container(
        color: ColoresBase.neutral50,
        // En desktop el alto es todo el disponible
        height: esDesktop.resolve(context) ? double.infinity : null,
        // en mobile el ancho es todo el disponible
        width: !esDesktop.resolve(context) ? double.infinity : null,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisSize: MainAxisSize.max,
              children: [
                titulo != null
                    ? Padding(
                        padding: const EdgeInsets.only(
                          top: Sizes.p10,
                          left: Sizes.p10,
                          right: Sizes.p10,
                        ),
                        child: Text(
                          titulo!,
                          style: const TextStyle(
                              fontSize: TextSizes.text2xl,
                              color: ColoresBase.neutral700,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.left,
                        ),
                      )
                    : const SizedBox(),
                Padding(
                  padding: EdgeInsets.only(
                      left: paddingContenedor, right: paddingContenedor),
                  child: child,
                )
              ]),
        ));
  }
}
