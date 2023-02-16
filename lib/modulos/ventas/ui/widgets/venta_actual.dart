//@visibleForTesting
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_campo_codigo_producto.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_dialogo_responsivo.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/acciones_de_venta.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:eleventa/modulos/ventas/ui/vista_cobrar.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/boton_cobrar.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/listado_articulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';

import 'package:eleventa/modulos/common/domain/moneda.dart';

class VentaActual extends ConsumerWidget {
  final TextEditingController campoCodigoController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Pago? _ultimoPagoSeleccionado;

  VentaActual({super.key});

  void dispose() {
    _focusNode.dispose();
  }

  /// Regresa una instancia de Pago si se hizo el cobro exitoso
  /// o [null] si el usuario canceló la operación
  Future<Pago?> _mostrarVistaCobro(
      BuildContext context, Moneda totalDeVenta) async {
    var val = await showDialog<Pago?>(
        context: context,
        // No permitimos que se cierre la vista de cobro salvo con ESC o con el boton Cancelar
        barrierDismissible: false,
        barrierLabel: 'vistaCobrar',
        builder: (BuildContext context) {
          return ExDialogoResponsivo<Pago?>(
              titulo: 'Cobrar Venta',
              onBotonPrimarioTap: () {
                // Regresamos el pago si se hizo tap en cobrar
                Navigator.of(context).pop(_ultimoPagoSeleccionado);
              },
              onBotonSecundarioTap: () {
                // Si se cancelo el cobro regresamos null
                Navigator.of(context).pop(null);
              },
              child: VistaCobrar(
                totalACobrar: totalDeVenta,
                onPagoSeleccionado: (Pago pago) {
                  // Almacenamos la ultima forma de pago seleccionada
                  // para si tiene exito el proceso de cobro
                  _ultimoPagoSeleccionado = pago;
                },
              ));
        });

    return val;
  }

  Future<void> _solicitarCobro(BuildContext context, Venta ventaEnProgreso,
      NotificadorVenta notifier) async {
    // Si la venta no tiene articulos no se puede cobrar
    if (ventaEnProgreso.articulos.isEmpty) {
      debugPrint('Sin articulos, cancelando cobro');
      return;
    }

    // Mostramos la vista de cobro
    var pago = await _mostrarVistaCobro(
      context,
      ventaEnProgreso.total,
    );

    // Si el pago es nulo es porque el usuario canceló el cobro
    if (pago == null) {
      debugPrint('Cobro cancelado, dejando de seguir');
      return;
    }

    // TODO: Validar que el pago recibido sea igual al total
    //var pagoCompleto = pago.copy !.monto = ventaEnProgreso.total;

    //if (context.mounted) return;

    // Cobramos la venta
    await _registrarCobroDeVenta(
      pago: pago,
      ventaEnProgreso: ventaEnProgreso,
      notifier: notifier,
    );
  }

  Future<void> _registrarCobroDeVenta({
    required Pago pago,
    required Venta ventaEnProgreso,
    required NotificadorVenta notifier,
  }) async {
    // Agregamos el pago a la venta
    ventaEnProgreso.agregarPago(pago);

    final cobrarVenta = ModuloVentas.cobrarVenta();
    cobrarVenta.req.venta = ventaEnProgreso;

    try {
      await cobrarVenta.exec();
      notifier.crearNuevaVenta();
    } catch (e) {
      debugPrint('Error: $e');
    }

    // Enfocamos de nuevo al campo código que es hijo del Focus widget
    if (_focusNode.children.first.canRequestFocus) {
      _focusNode.children.first.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final m = L10n.of(context);
    final isTabletOrDestkop = (context.breakpoint >= LayoutBreakpoint.md);

    final ventaEnProgreso = ref.watch(providerVenta);
    final notifier = ref.read(providerVenta.notifier);

    return isTabletOrDestkop
        ? Expanded(
            child: Row(
              children: [
                _ControlesVentaActual(
                  editingController: campoCodigoController,
                  focusNode: _focusNode,
                  onBuscarCodigo: notifier.agregarArticulo,
                ),
                Container(
                  width: 350,
                  padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 1,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0))),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: AccionesDeVenta(
                              focusNode: _focusNode,
                            ),
                          ),
                        ),
                      ),
                      BotonCobrarVenta(
                          totalDeVenta: ventaEnProgreso.venta.total.toDouble(),
                          onTap: () => _solicitarCobro(
                                context,
                                ventaEnProgreso.venta,
                                notifier,
                              ))
                    ],
                  ),
                )
              ],
            ),
          )
        : Expanded(
            child: Column(
              children: [
                _ControlesVentaActual(
                  editingController: campoCodigoController,
                  focusNode: _focusNode,
                  onBuscarCodigo: notifier.agregarArticulo,
                ),
                BotonCobrarVenta(
                    dense: true,
                    totalDeVenta: ventaEnProgreso.venta.total.toDouble(),
                    onTap: () => _solicitarCobro(
                          context,
                          ventaEnProgreso.venta,
                          notifier,
                        ))
              ],
            ),
          );
  }
}

class _ControlesVentaActual extends ConsumerWidget {
  final TextEditingController editingController;
  final Function onBuscarCodigo;
  final FocusNode focusNode;

  const _ControlesVentaActual(
      {required this.editingController,
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
