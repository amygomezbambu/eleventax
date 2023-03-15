//@visibleForTesting

import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_dialogos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/read_models/producto_generico.dart';
import 'package:eleventa/modulos/ventas/ui/dialogo_venta_rapida.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/boton_accion_de_venta.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/campo_codigo_producto.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/listado_articulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';

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
  final esDesktop = LayoutValue(xs: false, md: true);
  final TextEditingController editingController;
  final Function onBuscarCodigo;
  final FocusNode focusNode;

  ControlesVentaActual(
      {super.key,
      required this.editingController,
      required this.focusNode,
      required this.onBuscarCodigo});

  Future<void> _agregarProductoAListado(
      BuildContext context, WidgetRef ref, String codigo) async {
    if (codigo == "0") {
      await _solicitarVentaGenerico(context, ref, codigo);
    } else {
      await onBuscarCodigo(codigo);
    }

    editingController.clear();
  }

  Future<void> _solicitarVentaGenerico(
      BuildContext context, WidgetRef ref, String codigo) async {
    final productoGenerico =
        await ExDialogos.mostrarDialogo<ProductoGenericoDto>(
      context,
      titulo: 'Venta Rápida',
      mensaje: 'Ingresa los datos del producto a agregar',
      icono: Iconos.flash4,
      widgets: [const DialogoVentaRapida()],
    );

    if (productoGenerico != null) {
      final notifier = ref.read(providerVenta.notifier);
      await notifier.agregarVentaRapida(productoGenerico);
    }
  }

  void _seleccionarArticulo(WidgetRef ref, Articulo articuloSeleccionado) {
    final notifier = ref.read(providerVenta.notifier);
    notifier.seleccionarArticulo(articuloSeleccionado);
  }

  /// Cambia el control enfocado de acuerdo a las teclas de flecha arriba,
  /// flecha abajo y ENTER como en eleventa 5.
  KeyEventResult _cambiarControlEnFoco(BuildContext context, WidgetRef ref,
      FocusNode node, RawKeyEvent keyEvent) {
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
        _agregarProductoAListado(context, ref, editingController.text);
        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.delete) {
        // TODO: Tecla DELETE presionada borrar articulo
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
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: ColoresBase.neutral200,
                ),
              ),
              color: ColoresBase.neutral100,
            ),
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColoresBase.neutral200,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(children: [
                  CampoCodigoProducto(
                    textEditingController: editingController,
                    focusNode: focusNode,
                    onProductoElegido: (String codigoProducto) {
                      // TODO: Regresar mejor UUID?
                      _agregarProductoAListado(context, ref, codigoProducto);
                    },
                    onKey: (focus, key) {
                      return _cambiarControlEnFoco(context, ref, focus, key);
                    },
                  )
                ]),
              ),
            ),
          ),
          Expanded(
            child: ListadoArticulos(
                onSeleccionarArticulo: (articulo) =>
                    _seleccionarArticulo(ref, articulo)),
          ),
          !esDesktop.resolve(context)
              ? ControlesVentaMobile(onTap: () async {
                  await _solicitarVentaGenerico(context, ref, '0');
                })
              : const Center()
        ],
      ),
    );
  }
}

class ControlesVentaMobile extends StatelessWidget {
  final VoidCallback onTap;

  const ControlesVentaMobile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.p20,
      decoration: const BoxDecoration(
        color: ColoresBase.neutral100,
        border: Border(
          top: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
          bottom: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
        ),
      ),
      child: Row(
        children: [
          // TODO: Implementar controles de la venta
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: BotonAccionDeVenta(
              label: 'Venta Rápida',
              hintText: 'Venta de producto rapido',
              atajoTeclado: '0',
              icon: Iconos.flash4,
              enabled: true,
              onTap: onTap,
            ),
          )
        ],
      ),
    );
  }
}
