//@visibleForTesting
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_campo_codigo_producto.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/telemetria/modulo_telemetria.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/acciones_de_venta.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/boton_cobrar.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/listado_articulos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';

class VentaActual extends ConsumerWidget {
  final TextEditingController myController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  VentaActual({super.key});

  void dispose() {
    _focusNode.dispose();
  }

  void _cobrarVenta({
    required BuildContext context,
    required Venta ventaEnProgreso,
    required NotificadorVenta notifier,
  }) async {
    final cobrarVenta = ModuloVentas.cobrarVenta();
    final metricasCobro = ModuloTelemetria.enviarMetricasDeCobro();
    final idVenta = ventaEnProgreso.uid;

    // TODO: Cargar formas de pago desde la UI
    final consultas = ModuloVentas.repositorioConsultaVentas();
    var formasDePago = await consultas.obtenerFormasDePago();
    var pago = Pago.crear(
      forma: formasDePago.first,
      monto: ventaEnProgreso.total,
    );
    ventaEnProgreso.agregarPago(pago);

    cobrarVenta.req.venta = ventaEnProgreso;

    try {
      await cobrarVenta.exec();
      notifier.crearNuevaVenta();

      //TODO: implementar el caso de uso metricasCobro cuando se implemente cancelación del proceso de cobro
      var ventaCobrada = await consultas.obtenerVenta(idVenta);
      metricasCobro.req.venta = ventaCobrada;
      metricasCobro.req.tipo = TipoEventoTelemetria.cobroRealizado;
      await metricasCobro.exec();
    } catch (e) {
      debugPrint('Error');
    }

    // myController.clear();
    // myFocusNode.requestFocus();

    // // Para evitar fallas al cerrar la app checamos que la app siga "viva"
    // // ref: https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
    // if (!context.mounted) return;

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: const Text('Venta cobrada'),
    //   width: 300,
    //   //margin: EdgeInsets.only(bottom: -100),
    //   padding: const EdgeInsets.symmetric(
    //     vertical: 20,
    //     horizontal: 30.0, // Inner padding for SnackBar content.
    //   ),
    //   behavior: SnackBarBehavior.floating,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    // ));

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
                  editingController: myController,
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
                        onTap: () => _cobrarVenta(
                          context: context,
                          ventaEnProgreso: ventaEnProgreso.venta,
                          notifier: notifier,
                        ),
                      )
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
                  editingController: myController,
                  focusNode: _focusNode,
                  onBuscarCodigo: notifier.agregarArticulo,
                ),
                BotonCobrarVenta(
                  dense: true,
                  totalDeVenta: ventaEnProgreso.venta.total.toDouble(),
                  onTap: () => _cobrarVenta(
                    context: context,
                    ventaEnProgreso: ventaEnProgreso.venta,
                    notifier: notifier,
                  ),
                )
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
