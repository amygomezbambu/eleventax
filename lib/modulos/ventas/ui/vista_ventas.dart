import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_campo_codigo_producto.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/ventas/ui/boton_cobrar.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/modulos/ventas/ui/acciones_de_venta.dart';
import 'package:eleventa/modulos/ventas/ui/listado_articulos.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:layout/layout.dart';
import 'package:eleventa/l10n/generated/l10n.dart';

class VistaVentas extends StatefulWidget {
  const VistaVentas({Key? key, required String title}) : super(key: key);

  @override
  State<VistaVentas> createState() => _VistaVentasState();
}

class _VistaVentasState extends State<VistaVentas> {
  @override
  Widget build(BuildContext ctx) {
    var m = L10n.of(context);

    return VistaPrincipalScaffold(
      titulo: m.ventas_titulo,
      child: AdaptiveBuilder(
        xs: (context) => Column(
          children: [VentaActual()],
        ),
        md: (context) => Row(
          children: [
            Expanded(
              child: Row(
                children: [VentaActual()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//@visibleForTesting
class VentaActual extends ConsumerWidget {
  final FocusNode myFocusNode = FocusNode();
  final TextEditingController myController = TextEditingController();

  VentaActual({super.key});

  void seleccionarArticulo(int itemIndex) {
    // setState(() {
    //   UiCart.selectedItem = UiCart.items[itemIndex];
    // });

    myFocusNode.requestFocus();
  }

  void chargeButtonClick() async {
    debugPrint('Cobrando!');

    // var cobrarVenta = ModuloVentas.cobrarVenta();

    // // To-DO: Creo que la UI no debe tener acceso a las clases del Entity no?
    // // aqui necesite agregar el import para tener acceso el enum
    // cobrarVenta.req.metodoDePago = MetodoDePago.efectivo;
    // cobrarVenta.req.ventaUID = UiCart.saleUid;

    // await cobrarVenta.exec();

    // setState(() {
    //   saleTotal = 0.0;
    // });

    // UiCart.items.clear();
    // UiCart.saleUid = '';

    // myController.clear();
    // myFocusNode.requestFocus();

    // // Para evitar fallas al cerrar la app checamos que la app siga "viva"
    // // ref: https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
    // if (!mounted) return;

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text(m.ventas_ventaExitosa),
    //   width: 300,
    //   //margin: EdgeInsets.only(bottom: -100),
    //   padding: const EdgeInsets.symmetric(
    //     vertical: 20,
    //     horizontal: 30.0, // Inner padding for SnackBar content.
    //   ),
    //   behavior: SnackBarBehavior.floating,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    // ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final m = L10n.of(context);
    final isTabletOrDestkop = (context.breakpoint >= LayoutBreakpoint.md);

    final venta = ref.watch(providerVenta);
    final notifier = ref.read(providerVenta.notifier);

    return isTabletOrDestkop
        ? Expanded(
            child: Row(
              children: [
                ControlesVentaActual(
                    focusNode: myFocusNode,
                    editingController: myController,
                    onBuscarCodigo: notifier.agregarProducto,
                    seleccionarArticulo: seleccionarArticulo),
                Container(
                  width: 350,
                  padding: const EdgeInsets.fromLTRB(1, 5, 7, 5),
                  child: Column(
                    children: [
                      const Expanded(
                        child: Card(
                          elevation: 1,
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: AccionesDeVenta(),
                          ),
                        ),
                      ),
                      BotonCobrarVenta(
                        totalDeVenta: venta.total.toDouble(),
                        onTap: chargeButtonClick,
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
                ControlesVentaActual(
                  focusNode: myFocusNode,
                  editingController: myController,
                  onBuscarCodigo: notifier.agregarProducto,
                  seleccionarArticulo: seleccionarArticulo,
                ),
                BotonCobrarVenta(
                  dense: true,
                  totalDeVenta: venta.total.toDouble(),
                  onTap: chargeButtonClick,
                )
              ],
            ),
          );
  }
}

class ControlesVentaActual extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController editingController;
  final Function onBuscarCodigo;
  final Function seleccionarArticulo;
  final FocusNode _focusNode = FocusNode();

  ControlesVentaActual(
      {super.key,
      required this.focusNode,
      required this.editingController,
      required this.onBuscarCodigo,
      required this.seleccionarArticulo});

  void _agregarProductoAListado(String codigo) {
    onBuscarCodigo(codigo);
    editingController.clear();
    focusNode.requestFocus();
  }

  /// Cambia el control enfocado de acuerdo a las teclas de flecha arriba,
  /// flecha abajo y ENTER como en eleventa 5.
  KeyEventResult _cambiarControlEnFoco(FocusNode node, KeyEvent key) {
    if (key.logicalKey == LogicalKeyboardKey.arrowDown) {
      debugPrint('TODO: Cambiar control al de abajo');
      return KeyEventResult.handled;
    }

    if (key.logicalKey == LogicalKeyboardKey.arrowUp) {
      debugPrint('TODO: Cambiar control al de arriba si hay uno');
      return KeyEventResult.handled;
    }

    if (key.logicalKey == LogicalKeyboardKey.enter) {
      _agregarProductoAListado(editingController.text);
      return KeyEventResult.handled;
    }

    if (key.logicalKey == LogicalKeyboardKey.delete) {
      debugPrint('TODO: Tecla DELETE presionada borrar articulo');
      return KeyEventResult.handled;
    }

    if (key.logicalKey == LogicalKeyboardKey.numpadAdd) {
      debugPrint('TODO: Tecla NUMPAD+ presionada aumentar cantidad');
      return KeyEventResult.handled;
    }

    if (key.logicalKey == LogicalKeyboardKey.numpadSubtract) {
      debugPrint('TODO: Tecla NUMPAD- presionado disminuir cantidad');
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Focus(
            focusNode: _focusNode,
            onKeyEvent: _cambiarControlEnFoco,
            child: Card(
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
                    child: ExCampoCodigoProducto(
                      key: const ValueKey('skuField'),
                      hintText: 'Ingresa un código de producto...',
                      aplicarResponsividad: false,
                      controller: editingController,
                      // Solo aplica para dispositivos móviles:
                      onCodigoEscanado: _agregarProductoAListado,
                      onFieldSubmitted: _agregarProductoAListado,
                    ),
                  ),
                )),
          ),
          Expanded(
            child: ListadoArticulos(
                onSelectItem: (index) => {seleccionarArticulo(index)}),
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
