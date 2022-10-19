import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/boton_cobrar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tailwindcss_defaults/colors.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/ui/acciones_de_venta.dart';
import 'package:eleventa/modulos/ventas/ui/ui_sale_item.dart';
import 'package:eleventa/modulos/ventas/ui/listado_articulos.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/ventas/app/usecase/crear_venta.dart';
import 'package:eleventa/modulos/ventas/app/usecase/agregar_articulo.dart';
import 'package:layout/layout.dart';

class VistaVentas extends StatefulWidget {
  final String titulo;

  const VistaVentas({Key? key, required this.titulo}) : super(key: key);

  @override
  State<VistaVentas> createState() => _VistaVentasState();
}

class _VistaVentasState extends State<VistaVentas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveBuilder(
        xs: (context) => Column(
          children: const [VentaActual()],
        ),
        md: (context) => Row(
          children: [
            Expanded(
              child: Row(
                children: const [VentaActual()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VentaActual extends StatefulWidget {
  const VentaActual({
    Key? key,
  }) : super(key: key);

  @override
  State<VentaActual> createState() => VentaActualState();
}

@visibleForTesting
class VentaActualState extends State<VentaActual> {
  double saleTotal = 0.0;
  String currentSaleId = '';
  FocusNode myFocusNode = FocusNode();
  TextEditingController myController = TextEditingController();

  Future<void> agregarProducto(String value) async {
    // Obtenemos los Use cases...
    // ObtenerProducto obtenerProducto = ModuloProductos.obtenerProducto();
    CrearVenta crearVenta = ModuloVentas.crearVenta();
    AgregarArticulo agregarArticulo = ModuloVentas.agregarArticulo();

    //late Producto producto;

    // Checamos tener una venta
    if (UiCart.saleUid == '') {
      UiCart.saleUid = crearVenta.exec();
      debugPrint('Nueva venta creada $UiCart.saleUid');
    }

    // obtenerProducto.req.sku = value;

    try {
      // producto = await obtenerProducto.exec();

      // Agregamos el articulo a la venta
      // agregarArticulo.req.articulo.descripcion = producto.descripcion;
      // agregarArticulo.req.articulo.precio = producto.precio;
      agregarArticulo.req.articulo.cantidad = 1;
      agregarArticulo.req.ventaUID = UiCart.saleUid;

      // debugPrint('Agregando ${producto.descripcion} a venta ${UiCart.saleUid}');
      var sale = await agregarArticulo.exec();

      setState(() {
        // Si tuvimos exito, lo agregamos a la UI
        // UiCart.items.add(UiSaleItem(
        //     code: producto.sku,
        //     description: producto.descripcion,
        //     price: producto.precio.toString()));

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

  void seleccionarArticulo(int itemIndex) {
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
    final isTabletOrDestkop = (context.breakpoint >= LayoutBreakpoint.md);

    return isTabletOrDestkop
        ? Expanded(
            child: Row(
              children: [
                ControlesVentaActual(
                    focusNode: myFocusNode,
                    editingController: myController,
                    onBuscarCodigo: agregarProducto,
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
                        totalDeVenta: saleTotal,
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
                  onBuscarCodigo: agregarProducto,
                  seleccionarArticulo: seleccionarArticulo,
                ),
                BotonCobrarVenta(
                  dense: true,
                  totalDeVenta: saleTotal,
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

  const ControlesVentaActual(
      {super.key,
      required this.focusNode,
      required this.editingController,
      required this.onBuscarCodigo,
      required this.seleccionarArticulo});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
                    focusNode: focusNode,
                    controller: editingController,
                    onSubmitted: (String val) => {onBuscarCodigo(val)},
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
              child: ListadoArticulos(
                  articulos: UiCart.items,
                  onSelectItem: (index) => {seleccionarArticulo(index)})),
        ],
      ),
    );
  }
}
