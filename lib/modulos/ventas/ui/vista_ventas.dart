import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/impresora_tickets.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/adaptador_impresion_windows.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/impresora_tickets_windows.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_responsiva.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/telemetria/modulo_telemetria.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/acciones_de_venta.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:eleventa/modulos/ventas/ui/vista_cobrar.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/boton_cobrar.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/venta_actual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';
import 'package:eleventa/l10n/generated/l10n.dart';

class VistaVentas extends ConsumerStatefulWidget {
  static const keyCampoCodigo = Key('edtCampoCodigo');
  static const keyBotonCobrar = Key('btnCobrar');

  const VistaVentas({Key? key, required String title}) : super(key: key);

  @override
  VistaVentasState createState() => VistaVentasState();
}

class VistaVentasState extends ConsumerState<VistaVentas> {
  final TextEditingController campoCodigoController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Pago? _ultimoPagoSeleccionado;

  Future<void> _solicitarCobro(BuildContext context, Venta ventaEnProgreso,
      NotificadorVenta notifier) async {
    debugPrint('Solicitando cobro');
    if (ventaEnProgreso.articulos.isEmpty) {
      // TODO: UI - Mostrar mensaje de no es posible cobrar venta vacia
      debugPrint('Sin articulos, cancelando cobro');
      return;
    }

    var pago = await _mostrarVistaCobro(
      context,
      ventaEnProgreso.total,
    );

    if (pago == null) {
      // TODO: UI - Mostrar mensaje de cobro cancelado
      debugPrint('Cobro cancelado, dejando de seguir');
      return;
    }

    // TODO: Validar que el pago recibido sea igual al total
    //var pagoCompleto = pago.copy !.monto = ventaEnProgreso.total;

    //if (context.mounted) return;

    await _registrarCobroDeVenta(
      pago: pago,
      ventaEnProgreso: ventaEnProgreso,
      notifier: notifier,
    );
  }

  /// Regresa una instancia de [Pago] si se hizo el cobro exitoso
  /// o [null] si el usuario canceló la operación
  Future<Pago?> _mostrarVistaCobro(
      BuildContext context, Moneda totalDeVenta) async {
    // Dependiendo de la resolución de pantalla mostramos una vista u otra
    var valor = await mostrarVistaResponsiva<Pago?>(
      context: context,
      titulo: 'Cobrar Venta',
      labelBotonPrimario: 'Cobrar',
      labelBotonSecundario: 'Cancelar',
      onBotonPrimarioTap: (BuildContext ctx) {
        Navigator.of(ctx).pop(_ultimoPagoSeleccionado);
      },
      onBotonSecundarioTap: (BuildContext ctx) {
        Navigator.of(ctx).pop(null);
      },
      child: VistaCobrar(
        totalACobrar: totalDeVenta,
        onPagoSeleccionado: (Pago pago) {
          // Almacenamos la ultima forma de pago seleccionada
          // para si tiene exito el proceso de cobro
          _ultimoPagoSeleccionado = pago;
        },
        onCobroConcluido: () {
          /// Hemos concluido proceso de cobro mobile ya que al
          /// hacer tap en un botón lo damos por concluido
          Navigator.of(context).pop(_ultimoPagoSeleccionado);
        },
      ),
    );

    return valor;
  }

  Future<void> _registrarCobroDeVenta({
    required Pago pago,
    required Venta ventaEnProgreso,
    required NotificadorVenta notifier,
  }) async {
    ventaEnProgreso.agregarPago(pago);

    final cobrarVenta = ModuloVentas.cobrarVenta();
    cobrarVenta.req.venta = ventaEnProgreso;
    final metricasCobro = ModuloTelemetria.enviarMetricasDeCobro();
    final idVenta = ventaEnProgreso.uid;
    final consultas = ModuloVentas.repositorioConsultaVentas();

    //try {
    await cobrarVenta.exec();
    notifier.crearNuevaVenta();

    //TODO: implementar el caso de uso metricasCobro cuando se implemente cancelación del proceso de cobro
    var ventaCobrada = await consultas.obtenerVenta(idVenta);
    if (ventaCobrada != null) {
      metricasCobro.req.venta = ventaCobrada;
      metricasCobro.req.tipo = TipoEventoTelemetria.cobroRealizado;
      await metricasCobro.exec();

      //TODO: implementar el caso de uso de imprimir ticket de venta
      var adaptadorImpresion = AdaptadorImpresionWindows();
      var impresoraTickets = ImpresoraDeTicketsWindows(
        nombreImpresora: appConfig.nombreImpresora,
        anchoTicket: AnchoTicket.mm58,
      );

      adaptadorImpresion.impresoraTickets = impresoraTickets;
      await adaptadorImpresion.imprimirTicket(ventaCobrada);
    }
    // } catch (e) {
    //   debugPrint('Error: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Error al cobrar venta'),
    //     ),
    //   );
    // }

    // Enfocamos de nuevo al campo código que es hijo del Focus widget
    if (_focusNode.children.first.canRequestFocus) {
      _focusNode.children.first.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    var m = L10n.of(context);

    final ventaEnProgreso = ref.watch(providerVenta);
    final notifier = ref.read(providerVenta.notifier);

    return VistaPrincipalScaffold(
      titulo: m.ventas_titulo,
      child: AdaptiveBuilder(
        xs: (context) => Column(
          children: [
            VistaVentasMobile(
              controller: campoCodigoController,
              focusNode: _focusNode,
              totalVentaActual: ventaEnProgreso.venta.total,
              onSolicitarCobro: () => _solicitarCobro(
                context,
                ventaEnProgreso.venta,
                notifier,
              ),
            ),
          ],
        ),
        md: (context) => VistaVentasDesktop(
            controller: campoCodigoController,
            focusNode: _focusNode,
            totalVentaActual: ventaEnProgreso.venta.total,
            onSolicitarCobro: () => _solicitarCobro(
                  context,
                  ventaEnProgreso.venta,
                  notifier,
                )),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }
}

class VistaVentasMobile extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Moneda totalVentaActual;
  final VoidCallback onSolicitarCobro;

  const VistaVentasMobile(
      {Key? key,
      required this.controller,
      required this.focusNode,
      required this.totalVentaActual,
      required this.onSolicitarCobro})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Solo mostramos la venta y el botón de cobrar
    return Expanded(
      child: Column(
        children: [
          VentaActual(
            controller: controller,
            focusNode: focusNode,
          ),
          BotonCobrarVenta(
              dense: true,
              // TODO: Localizar
              totalDeVenta: totalVentaActual.toDouble(),
              onTap: onSolicitarCobro),
        ],
      ),
    );
  }
}

/// Vista especifica para el layout desktop
class VistaVentasDesktop extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Moneda totalVentaActual;
  final VoidCallback onSolicitarCobro;

  const VistaVentasDesktop({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSolicitarCobro,
    required this.totalVentaActual,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    VentaActual(
                      controller: controller,
                      focusNode: focusNode,
                    ),
                    ColumnaControlesDeVenta(
                        focusNode: focusNode,
                        totalVentaActual: totalVentaActual,
                        onSolicitarCobro: onSolicitarCobro)
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ColumnaControlesDeVenta extends StatelessWidget {
  final FocusNode focusNode;
  final Moneda totalVentaActual;
  final VoidCallback onSolicitarCobro;

  const ColumnaControlesDeVenta({
    super.key,
    required this.focusNode,
    required this.totalVentaActual,
    required this.onSolicitarCobro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: Column(
        children: [
          Expanded(
            child: Card(
              elevation: 1,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(0))),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: AccionesDeVenta(
                  focusNode: focusNode,
                ),
              ),
            ),
          ),
          BotonCobrarVenta(
            // TODO: Cambiar a localizado
            totalDeVenta: totalVentaActual.toDouble(),
            onTap: onSolicitarCobro,
          ),
        ],
      ),
    );
  }
}
