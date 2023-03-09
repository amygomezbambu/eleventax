import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VentaActualState {
  late Articulo articuloSeleccionado;
  late Venta _venta;
  Venta get venta => _venta;

  VentaActualState() {
    _venta = Venta.crear();
  }

  VentaActualState.cargar({
    required Venta venta,
    required Articulo articulo,
  })  : _venta = venta,
        articuloSeleccionado = articulo;

  VentaActualState copyWith({
    Venta? venta,
    Articulo? articulo,
  }) {
    return VentaActualState.cargar(
      venta: venta ?? _venta,
      articulo: articulo ?? articuloSeleccionado,
    );
  }
}

//crear notificador
class NotificadorVenta extends StateNotifier<VentaActualState> {
  final consultas = Dependencias.productos.repositorioConsultasProductos();
  final guardarVentaEnProgreso = ModuloVentas.guardarVenta();

  NotificadorVenta() : super(VentaActualState());

  Future<void> _guardarVenta() async {
    guardarVentaEnProgreso.req.venta = state.venta;
    await guardarVentaEnProgreso.exec();
  }

  Future<void> agregarArticulo(String value) async {
    try {
      var producto =
          await consultas.obtenerProductoPorCodigo(CodigoProducto(value));

      if (producto == null) {
        // TODO: Mostrar mensaje de error en la UI
        debugPrint('PRODUCTO NO ENCONTRADO!!');
      } else {
        state.venta.agregarArticulo(Articulo.crear(
          producto: producto,
          cantidad: 1.00,
        ));

        await _guardarVenta();

        // El articulo seleccionado será el último si es nuevo
        // o el que ya exista si tiene el mismo código de producto
        state.articuloSeleccionado = state.venta.articulos.firstWhere(
            (element) =>
                element.producto.codigo == CodigoProducto(value).value);
      }
    } on Exception catch (e) {
      // TODO: mostrar mensaje de error o decidir que hacer
      debugPrint(e.toString());
    }

    state = state.copyWith();
  }

  void crearNuevaVenta() {
    // Reiniciamos el estado porque es una nueva venta
    super.state = VentaActualState();
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
    await _modificarCantidad(1);
  }

  Future<void> disminuirCantidad() async {
    await _modificarCantidad(-1);
  }

  Future<void> _modificarCantidad(double cantidad) async {
    final articuloActualizado = state.articuloSeleccionado
        .copyWith(cantidad: state.articuloSeleccionado.cantidad + cantidad);
    state.venta.actualizarArticulo(articuloActualizado);

    state = state.copyWith();
    await _guardarVenta();
  }
}

final providerVenta = StateNotifierProvider<NotificadorVenta, VentaActualState>(
    (ref) => NotificadorVenta());
