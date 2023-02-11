import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VentaEnProgreso {
  var consultas = Dependencias.productos.repositorioConsultasProductos();
  late Articulo articuloSeleccionado;
  late Venta _venta;
  Venta get venta => _venta;

  VentaEnProgreso() {
    _venta = Venta.crear();
  }

  VentaEnProgreso.cargar({
    required Venta venta,
    required Articulo articulo,
  })  : _venta = venta,
        articuloSeleccionado = articulo;

  Future<void> agregarProducto(String value) async {
    var consultas = ModuloProductos.repositorioConsultaProductos();

    try {
      var producto =
          await consultas.obtenerProductoPorCodigo(CodigoProducto(value));

      if (producto == null) {
        // TODO: Mostrar mensaje de error en la UI
      } else {
        // El articulo seleccionado siempre será el ultimo
        venta.agregarArticulo(
            Articulo.crear(producto: producto, cantidad: 1.00));

        articuloSeleccionado = venta.articulos
            .firstWhere((element) => element.producto.codigo == value);
      }
    } on Exception catch (e) {
      if (e is AppEx) {
        // TODO: mostrar mensaje de error o decidir que hacer
        debugPrint(e.message);
      }
    }
  }

  VentaEnProgreso copyWith({
    Venta? venta,
    Articulo? articulo,
  }) {
    return VentaEnProgreso.cargar(
      venta: venta ?? _venta,
      articulo: articulo ?? articuloSeleccionado,
    );
  }
}

//crear notificador
class NotificadorVenta extends StateNotifier<VentaEnProgreso> {
  NotificadorVenta() : super(VentaEnProgreso());

  Future<void> agregarArticulo(String value) async {
    await state.agregarProducto(value);
    state = state.copyWith();
  }

  void seleccionarArticulo(Articulo articulo) {
    state.articuloSeleccionado = articulo;
    state = state.copyWith();
  }

  void seleccionarArticuloSiguiente() {
    // Si es el ultimo articulo, no intentamos avanzar
    if (state.articuloSeleccionado == state.venta.articulos.last) return;

    var indiceArticuloActual =
        state.venta.articulos.indexOf(state.articuloSeleccionado);

    seleccionarArticulo(state.venta.articulos[indiceArticuloActual + 1]);
  }

  void seleccionarArticuloAnterior() {
    // Si es el primer articulo, no intentamos retroceder
    if (state.articuloSeleccionado == state.venta.articulos.first) return;

    var indiceArticuloActual =
        state.venta.articulos.indexOf(state.articuloSeleccionado);
    seleccionarArticulo(state.venta.articulos[indiceArticuloActual - 1]);
  }

  Future<void> aumentarCantidad() async {
    // TODO: La venta ahorita "no se entera" del cambio de cantidad, ver cómo hacerle
    state.articuloSeleccionado
        .actualizarCantidad(state.articuloSeleccionado.cantidad + 1.00);
    state = state.copyWith();
  }

  Future<void> disminuirCantidad() async {
    state.articuloSeleccionado
        .actualizarCantidad(state.articuloSeleccionado.cantidad - 1.00);
    state = state.copyWith();
  }
}

final providerVenta = StateNotifierProvider<NotificadorVenta, VentaEnProgreso>(
    (ref) => NotificadorVenta());
