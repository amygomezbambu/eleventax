//@visibleForTesting
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_campo_codigo_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/listado_articulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Representa una venta actual, el campo de código de barras y el listado de
/// artículos de una venta en progreso. Es responsivo y se adapta a la pantalla
/// del dispositivo.
class VentaActual extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const VentaActual(
      {required this.controller, required this.focusNode, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(providerVenta.notifier);

    return ControlesVentaActual(
      editingController: controller,
      focusNode: focusNode,
      onBuscarCodigo: notifier.agregarArticulo,
    );
  }
}

class ControlesVentaActual extends ConsumerWidget {
  final TextEditingController editingController;
  final Function onBuscarCodigo;
  final FocusNode focusNode;

  const ControlesVentaActual(
      {super.key,
      required this.editingController,
      required this.focusNode,
      required this.onBuscarCodigo});

  void _agregarProductoAListado(String codigo) {
    onBuscarCodigo(codigo);
    editingController.clear();
  }

  void _seleccionarArticulo(WidgetRef ref, Articulo articuloSeleccionado) {
    final notifier = ref.read(providerVenta.notifier);

    notifier.seleccionarArticulo(articuloSeleccionado);

    // Enfocamos de nuevo al campo código que es hijo del Focus widget
    if (focusNode.children.first.canRequestFocus) {
      focusNode.children.first.requestFocus();
    }
  }

  /// Cambia el control enfocado de acuerdo a las teclas de flecha arriba,
  /// flecha abajo y ENTER como en eleventa 5.
  KeyEventResult _cambiarControlEnFoco(
      WidgetRef ref, FocusNode node, RawKeyEvent keyEvent) {
    final notifier = ref.read(providerVenta.notifier);

    if (keyEvent is RawKeyDownEvent) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
        notifier.seleccionarArticuloSiguiente();
        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
        notifier.seleccionarArticuloAnterior();
        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
        _agregarProductoAListado(editingController.text);
        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.delete) {
        debugPrint('TODO: Tecla DELETE presionada borrar articulo');
        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.numpadAdd) {
        // TODO: Ver cómo avisarle a la Venta y por tanto otros widgets que el total
        // de la misma cambió, no solo del articulo
        notifier.aumentarCantidad();
        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.numpadSubtract) {
        notifier.disminuirCantidad();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(0),
            borderOnForeground: false,
            elevation: 1.0,
            shape: const RoundedRectangleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColoresBase.neutral200,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Focus(
                    focusNode: focusNode,
                    debugLabel: 'focoCampoCodigo',
                    onKey: (FocusNode node, RawKeyEvent key) =>
                        _cambiarControlEnFoco(ref, node, key),
                    child: ExCampoCodigoProducto(
                      key: const ValueKey('skuField'),
                      hintText: 'Ingresa un código de producto...',
                      aplicarResponsividad: false,
                      controller: editingController,
                      // Solo aplica para dispositivos móviles:
                      onCodigoEscanado: _agregarProductoAListado,
                      onFieldSubmitted: _agregarProductoAListado,
                    )),
              ),
            ),
          ),
          Expanded(
            child: ListadoArticulos(
                onSeleccionarArticulo: (articulo) =>
                    _seleccionarArticulo(ref, articulo)),
          ),
          Container(
            height: 90,
            color: ColoresBase.neutral200,
            child: Row(
              children: const [
                // TODO: Implementar controles de la venta
              ],
            ),
          )
        ],
      ),
    );
  }
}
