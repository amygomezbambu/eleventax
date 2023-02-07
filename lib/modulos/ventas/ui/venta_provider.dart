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
    } on Exception catch (e) {
      if (e is AppEx) {
        // TODO: mostrar mensaje de error o decidir que hacer
        debugPrint(e.message);
      }
    }
  }
}

//crear provider

final providerVenta =
    StateNotifierProvider<NotificadorVenta, Venta>((ref) => NotificadorVenta());
