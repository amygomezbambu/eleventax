import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_detalle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:layout/layout.dart';

/// Genera una vista siguiendo el patrón de maestro detalle responsivo:
/// En dispositivos móviles, el listado se muestra en pantalla completa. Al
///  seleccionar un elemento, se muestra el detalle en pantalla completa.
/// En dispositivos de escritorio, el listado se muestra a la izquierda y el
/// detalle del elemento seleccionado en la derecha.
class ExVistaMaestroDetalle extends StatefulWidget {
  final String title;
  final String rutaDetalleModal;
  final List<IListadoResponsivoItem> items;
  final double desktopWidth;
  final double factorAnchoDesktop;
  final int indiceItemSeleccionInicial;

  const ExVistaMaestroDetalle({
    super.key,
    required this.items,
    required this.title,
    this.rutaDetalleModal = 'detalle-modal-responsivo',
    this.desktopWidth = Sizes.p72,
    this.factorAnchoDesktop = 0.7,
    this.indiceItemSeleccionInicial = 0,
  });

  @override
  State<ExVistaMaestroDetalle> createState() => _ExVistaMaestroDetalleState();
}

class _ExVistaMaestroDetalleState extends State<ExVistaMaestroDetalle> {
  final esDesktop = LayoutValue(xs: false, md: true);
  int? _indiceSeleccionado;
  String tituloItemSeleccionado = '';
  Widget? widgetViewSeleccionado;

  void _navegarDetalleModal(
      {required BuildContext context,
      required String rutaDetalleModal,
      required String tituloVista,
      required Widget vistaDetalle}) {
    GoRouter.of(context).pushNamed(rutaDetalleModal,
        params: {
          'titulo': tituloVista,
        },
        extra: vistaDetalle);
  }

  void _mostrarDetalleEnPanelDerecho(
      {required BuildContext context,
      required int nuevoIndice,
      required String tituloVista,
      required Widget vistaDetalle}) {
    setState(() {
      _indiceSeleccionado = nuevoIndice;
      tituloItemSeleccionado = tituloVista;
      widgetViewSeleccionado = vistaDetalle;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Seleccionamos el primer elemento de la lista?
    if ((_indiceSeleccionado == null) && (widget.items.isNotEmpty)) {
      final itemSeleccionadoInicial =
          widget.items[widget.indiceItemSeleccionInicial];
      _mostrarDetalleEnPanelDerecho(
          context: context,
          nuevoIndice: widget.indiceItemSeleccionInicial,
          tituloVista: itemSeleccionadoInicial.tituloVentana(),
          vistaDetalle: itemSeleccionadoInicial.buildChildView(context));
    }

    return Scaffold(
      appBar: !esDesktop.resolve(context)
          ? ExAppBar(
              titleText: widget.title,
            )
          : null,
      body: Column(
        children: [
          esDesktop.resolve(context)
              ? _EncabezadoMaestroDesktop(
                  widget: widget,
                  tituloItemSeleccionado: tituloItemSeleccionado,
                  esDesktop: esDesktop)
              : const SizedBox(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: esDesktop.resolve(context)
                      ? widget.desktopWidth
                      : MediaQuery.of(context).size.width,
                  height: esDesktop.resolve(context)
                      ? MediaQuery.of(context).size.height
                      : null,
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
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final seleccionado = (index == _indiceSeleccionado) &&
                              esDesktop.resolve(context);

                          return ListTile(
                              leading: item.buildLeading(
                                context,
                                selecciondo: seleccionado,
                              ),
                              title: item.buildTitle(
                                context,
                                seleccionado: seleccionado,
                              ),
                              subtitle: item.buildSubtitle(
                                context,
                                selecciondo: seleccionado,
                              ),
                              trailing: item.buildTrailing(
                                context,
                                selecciondo: seleccionado,
                              ),
                              dense: !esDesktop.resolve(context),
                              visualDensity: VisualDensity.comfortable,
                              minLeadingWidth: 5,
                              horizontalTitleGap: 10,
                              selected: seleccionado,
                              selectedTileColor: ColoresBase.neutral300,
                              hoverColor: seleccionado
                                  ? ColoresBase.neutral300
                                  : item.esSeleccionable()
                                      ? ColoresBase.neutral200
                                      : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Sizes.p2),
                              ),
                              onTap: item.esSeleccionable()
                                  ? () {
                                      if (esDesktop.resolve(context)) {
                                        _mostrarDetalleEnPanelDerecho(
                                            context: context,
                                            nuevoIndice: index,
                                            tituloVista: item.tituloVentana(),
                                            vistaDetalle:
                                                item.buildChildView(context));
                                      } else {
                                        _navegarDetalleModal(
                                            context: context,
                                            rutaDetalleModal:
                                                widget.rutaDetalleModal,
                                            tituloVista: item.tituloVentana(),
                                            vistaDetalle:
                                                item.buildChildView(context));
                                      }
                                    }
                                  : null);
                        },
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(left: 45, right: 0),
                          child: Divider(
                            height: 0,
                            color: ColoresBase.neutral200,
                            thickness: Sizes.px,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                esDesktop.resolve(context)
                    ? Expanded(
                        child: VistaDetalle(
                          factorAnchoDesktop: widget.factorAnchoDesktop,
                          child: widgetViewSeleccionado ?? const Text(''),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EncabezadoMaestroDesktop extends StatelessWidget {
  final ExVistaMaestroDetalle widget;
  final String tituloItemSeleccionado;
  final LayoutValue<bool> esDesktop;

  const _EncabezadoMaestroDesktop({
    required this.widget,
    required this.tituloItemSeleccionado,
    required this.esDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            height: Sizes.p14,
            width: widget.desktopWidth,
            child: _TituloPanelDesktop(widget: widget)),
        Expanded(
          child: _TituloDetalleDesktop(
            title: tituloItemSeleccionado,
            esDesktop: esDesktop,
          ),
        ),
      ],
    );
  }
}

class _TituloDetalleDesktop extends StatelessWidget {
  final String title;

  const _TituloDetalleDesktop({
    required this.esDesktop,
    required this.title,
  });

  final LayoutValue<bool> esDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: esDesktop.resolve(context) ? Sizes.p14 : Sizes.p20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColoresBase.neutral100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(4, 8), // Shadow positionges position of shadow
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}

class _TituloPanelDesktop extends StatelessWidget {
  const _TituloPanelDesktop({
    required this.widget,
  });

  final ExVistaMaestroDetalle widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColoresBase.neutral100.withAlpha(200),
        border: const Border(
          bottom: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
          right: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
        ),
      ),
      child: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }
}

abstract class IListadoResponsivoItem {
  String tituloVentana();

  bool esSeleccionable();

  Widget buildTitle(BuildContext context, {bool seleccionado = false});

  Widget? buildSubtitle(BuildContext context, {bool selecciondo = false}) {
    return null;
  }

  Widget? buildLeading(BuildContext context, {bool selecciondo = false});

  Widget? buildTrailing(BuildContext context, {bool selecciondo = false});

  Widget buildChildView(BuildContext context);
}

class ListadoResponsivoItem implements IListadoResponsivoItem {
  @override
  Widget? buildLeading(BuildContext context, {bool selecciondo = false}) {
    return null;
  }

  @override
  Widget? buildSubtitle(BuildContext context, {bool selecciondo = false}) {
    return null;
  }

  @override
  Widget buildTitle(BuildContext context, {bool seleccionado = false}) {
    throw UnimplementedError('No se implementó el método buildTitle');
  }

  @override
  Widget? buildTrailing(BuildContext context, {bool selecciondo = false}) {
    return null;
  }

  @override
  String tituloVentana() {
    throw UnimplementedError('No se implementó el método tituloVentana');
  }

  @override
  Widget buildChildView(BuildContext context) {
    throw UnimplementedError('No se implementó el método buildChildView');
  }

  @override
  bool esSeleccionable() {
    return true;
  }
}
