import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:eleventa/modulos/common/ui/boton_primario.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/ui/sale_items_actions.dart';
import 'package:eleventa/modulos/ventas/ui/ui_sale_item.dart';
import 'package:eleventa/modulos/ventas/ui/sale_item_list_view.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/app/dto/producto_dto.dart';
import 'package:eleventa/modulos/productos/app/usecase/obtener_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/app/usecase/crear_venta.dart';
import 'package:eleventa/modulos/ventas/app/usecase/agregar_articulo.dart';

class VistaVentas extends StatefulWidget {
  final String titulo;

  const VistaVentas({Key? key, required this.titulo}) : super(key: key);

  @override
  State<VistaVentas> createState() => _VistaVentasState();
}

class _VistaVentasState extends State<VistaVentas> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext ctx, BoxConstraints constraints) {
      // Desktop / Tablet view
      if (constraints.maxWidth >= 800) {
        return Scaffold(
            body: Row(
          children: [
            Expanded(
              child: Row(
                children: const [
                  ContenedorArticulosDeVenta(),
                ],
              ),
            ),
          ],
        ));
      } else {
        // Mobile
        return Scaffold(
            body: Column(
          children: const [ContenedorArticulosDeVenta()],
        ));
      }
    });
  }
}

class NavigationButton extends StatelessWidget {
  final IconData icon;

  const NavigationButton(
    this.icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Icon(
        icon,
        color: TailwindColors.blueGray.shade200,
      ),
    );
  }
}

class ContenedorArticulosDeVenta extends StatefulWidget {
  const ContenedorArticulosDeVenta({
    Key? key,
  }) : super(key: key);

  @override
  State<ContenedorArticulosDeVenta> createState() =>
      ContenedorArticulosDeVentaState();
}

@visibleForTesting
class ContenedorArticulosDeVentaState
    extends State<ContenedorArticulosDeVenta> {
  double saleTotal = 0.0;
  String currentSaleId = '';
  FocusNode myFocusNode = FocusNode();
  TextEditingController myController = TextEditingController();

  Future<void> addItemBySku(String value) async {
    // Obtenemos los Use cases...
    ObtenerProducto obtenerProducto = ModuloProductos.obtenerProducto();
    CrearVenta crearVenta = ModuloVentas.crearVenta();
    AgregarArticulo agregarArticulo = ModuloVentas.agregarArticulo();

    late ProductoDTO producto;

    // Checamos tener una venta
    if (UiCart.saleUid == '') {
      UiCart.saleUid = crearVenta.exec();
      debugPrint('Nueva venta creada $UiCart.saleUid');
    }

    obtenerProducto.req.sku = value;

    try {
      producto = await obtenerProducto.exec();

      // Agregamos el articulo a la venta
      agregarArticulo.req.articulo.descripcion = producto.descripcion;
      agregarArticulo.req.articulo.precio = producto.precio;
      agregarArticulo.req.articulo.cantidad = 1;
      agregarArticulo.req.ventaUID = UiCart.saleUid;

      debugPrint('Agregando ${producto.descripcion} a venta ${UiCart.saleUid}');
      var sale = await agregarArticulo.exec();

      setState(() {
        // Si tuvimos exito, lo agregamos a la UI
        UiCart.items.add(UiSaleItem(
            code: producto.sku,
            description: producto.descripcion,
            price: producto.precio.toString()));

        UiCart.selectedItem = UiCart.items.last;
        UiCart.total = sale.total;

        saleTotal = sale.total;
      });
    } on Exception catch (e) {
      if (e is AppEx) {
        debugPrint(e.message);
      }
    }

    myController.clear();
    myFocusNode.requestFocus();
  }

  void selectItem(int itemIndex) {
    setState(() {
      UiCart.selectedItem = UiCart.items[itemIndex];
    });

    myFocusNode.requestFocus();
  }

  void chargeButtonClick() async {
    debugPrint('Cobrando!');

    var cobrarVenta = ModuloVentas.cobrarVenta();

    // To-DO: Creo que la UI no debe tener acceso a las clases del Entity no?
    // aqui necesite agregar el import para tener acceso el enum
    cobrarVenta.req.metodoDePago = MetodoDePago.efectivo;
    cobrarVenta.req.ventaUID = UiCart.saleUid;

    await cobrarVenta.exec();

    setState(() {
      saleTotal = 0.0;
    });

    UiCart.items.clear();
    UiCart.saleUid = '';

    myController.clear();
    myFocusNode.requestFocus();

    // Para evitar fallas al cerrar la app checamos que la app siga "viva"
    // ref: https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Gracias por su compra, ¡Vuelva pronto!'),
      width: 300,
      //margin: EdgeInsets.only(bottom: -100),
      padding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 30.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TBD: Sacar el breakpoint para desktop de estandares o un paquete auxilair
    return MediaQuery.of(context).size.width > 800
        ? Expanded(
            child: Row(
              children: [
                Expanded(
                  child: saleControls(),
                ),
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
                            child: SaleItemsActions(),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(3, 10, 5, 10),
                        height: 60,
                        child: BotonPrimario(
                            'Cobrar \$${saleTotal.toStringAsFixed(2)}',
                            Icons.attach_money_outlined,
                            chargeButtonClick,
                            key: const ValueKey('payButton')),
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
                Expanded(child: saleControls()),
                Container(
                  margin: const EdgeInsets.all(10),
                  height: 60,
                  child: BotonPrimario(
                    'Cobrar \$${saleTotal.toStringAsFixed(2)}',
                    Icons.attach_money_outlined,
                    chargeButtonClick,
                    key: const ValueKey('payButton'),
                  ),
                )
              ],
            ),
          );
  }

  Column saleControls() {
    return Column(
      children: [
        Card(
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: TailwindColors.blueGray[200], //ui.neutral300,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  key: const ValueKey('skuField'),
                  obscureText: false,
                  autofocus: true,
                  focusNode: myFocusNode,
                  controller: myController,
                  onSubmitted: addItemBySku,
                  autocorrect: false,
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.document_scanner,
                        color: TailwindColors.blueGray[300],
                      ),
                      border: InputBorder.none,
                      hintText: "Escanea o ingresa un código de producto...",
                      hintStyle: TextStyle(
                          fontSize: 15, color: TailwindColors.blueGray[400])),
                ),
              ),
            )),
        Expanded(
            child:
                ItemsListView(items: UiCart.items, onSelectItem: selectItem)),
      ],
    );
  }
}
