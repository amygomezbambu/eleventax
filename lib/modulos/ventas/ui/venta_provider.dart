import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//crear notificador
class NotificadorVenta extends StateNotifier<Venta> {
  var consultas = Dependencias.productos.repositorioConsultasProductos();

  NotificadorVenta() : super(Venta.crear());

  Future<void> agregarProducto(String value) async {
    var consultas = ModuloProductos.repositorioConsultaProductos();

    try {
      var producto =
          await consultas.obtenerProductoPorCodigo(CodigoProducto(value));

      if (producto == null) {
      } else {
        state.agregarArticulo(
          Articulo.crear(producto: producto, cantidad: 1.00),
        );

        state = state.copyWith();
      }

      // Agregamos el articulo a la venta
      // agregarArticulo.req.articulo.descripcion = producto.descripcion;
      // agregarArticulo.req.articulo.precio = producto.precio;
      // agregarArticulo.req.articulo.cantidad = 1;
      // agregarArticulo.req.ventaUID = UiCart.saleUid;

      // // debugPrint('Agregando ${producto.descripcion} a venta ${UiCart.saleUid}');
      // var sale = await agregarArticulo.exec();

      // setState(() {
      //   // Si tuvimos exito, lo agregamos a la UI
      //   // UiCart.items.add(UiSaleItem(
      //   //     code: producto.sku,
      //   //     description: producto.descripcion,
      //   //     price: producto.precio.toString()));

      //   UiCart.selectedItem = UiCart.items.last;
      //   UiCart.total = sale.total;

      //   saleTotal = sale.total;
      // });
    } on Exception catch (e) {
      if (e is AppEx) {
        debugPrint(e.message);
      }
    }

    // myController.clear();
    // myFocusNode.requestFocus();
  }
}

//crear provider

final providerVenta =
    StateNotifierProvider<NotificadorVenta, Venta>((ref) => NotificadorVenta());
