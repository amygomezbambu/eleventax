import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/productos/dto/busqueda_producto_dto.dart';
import 'package:eleventa/modulos/productos/ui/widgets/avatar_producto.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class ResultadosDeBusqueda extends StatelessWidget {
  final bool buscando;
  final String query;
  final ValueSetter<BusquedaProductoDto> onProductoSeleccionado;
  final int? selectedIndex;
  final List<BusquedaProductoDto> resultados;

  const ResultadosDeBusqueda({
    Key? key,
    required this.query,
    required this.onProductoSeleccionado,
    required this.selectedIndex,
    required this.resultados,
    required this.buscando,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 35,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Sizes.p2),
          bottomRight: Radius.circular(Sizes.p2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: resultados.isNotEmpty
                ? ColoresBase.primario600
                : ColoresBase.primario700,
            child: ListTile(
                dense: true,
                horizontalTitleGap: 0,
                title: Text(
                    resultados.isNotEmpty
                        ? "${resultados.length} productos encontrados para '$query'"
                        : "No se encontraron productos para '$query'",
                    style: TextStyle(
                      color: resultados.isNotEmpty
                          ? ColoresBase.neutral100
                          : ColoresBase.neutral50,
                    )),
                trailing: resultados.isNotEmpty
                    ? const Text(
                        'Usa las teclas de ↑ y ↓ para elegir un resultado',
                        style: TextStyle(
                          fontSize: 10,
                          color: ColoresBase.primario200,
                        ))
                    : null),
          ),
          const Divider(height: 0),
          LimitedBox(
            maxHeight: MediaQuery.of(context).size.height,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: resultados.length,
              separatorBuilder: (_, __) => const Divider(
                height: 0,
                color: ColoresBase.neutral300,
              ),
              itemBuilder: (context, i) {
                final producto = resultados.elementAt(i);
                return ListTile(
                  visualDensity: VisualDensity.comfortable,
                  dense: (context.breakpoint <= LayoutBreakpoint.sm),
                  leading: AvatarProducto(
                    uniqueId: producto.productoUid,
                    productName: producto.nombre,
                  ),
                  subtitle: Text(producto.codigo),
                  selected: (selectedIndex != null) && (i == selectedIndex),
                  tileColor: ColoresBase.neutral200,
                  selectedColor: ColoresBase.neutral800,
                  selectedTileColor: ColoresBase.primario300,
                  hoverColor: ColoresBase.neutral300,
                  title: HighlightText(
                    highlight: query,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                    highlightStyle:
                        const TextStyle(fontWeight: FontWeight.normal),
                    text: producto.nombre,
                  ),
                  trailing: Wrap(spacing: 80, children: <Widget>[
                    Text(
                      producto.precioDeVenta.toString(),
                      style: const TextStyle(
                          fontSize: 18,
                          color: ColoresBase.neutral600,
                          fontWeight: FontWeight.w600),
                    )
                  ]),
                  onTap: () => onProductoSeleccionado(producto),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HighlightText extends StatelessWidget {
  final String? text;
  final String highlight;
  final TextStyle style;
  final TextStyle highlightStyle;
  final bool ignoreCase;

  const HighlightText({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    required this.highlightStyle,
    this.ignoreCase = true,
  });

  @override
  Widget build(BuildContext context) {
    final text = this.text ?? '';
    if ((highlight.isEmpty) || text.isEmpty) {
      return Text(text, style: style);
    }

    var sourceText = ignoreCase ? text.toLowerCase() : text;
    var targetHighlight = ignoreCase ? highlight.toLowerCase() : highlight;

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfHighlight;
    do {
      indexOfHighlight = sourceText.indexOf(targetHighlight, start);
      if (indexOfHighlight < 0) {
        // no highlight
        spans.add(_normalSpan(text.substring(start)));
        break;
      }
      if (indexOfHighlight > start) {
        // normal text before highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
      }
      start = indexOfHighlight + highlight.length;
      spans.add(_highlightSpan(text.substring(indexOfHighlight, start)));
    } while (true);

    return Text.rich(TextSpan(children: spans));
  }

  TextSpan _highlightSpan(String content) {
    return TextSpan(text: content, style: highlightStyle);
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content, style: style);
  }
}
