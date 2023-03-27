import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto_generico.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/ventas/domain/articulo.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/read_models/producto_generico.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VentaActualState {
  Articulo? articuloSeleccionado;
  late Venta _venta;
  Venta get venta => _venta;

  VentaActualState() {
    _venta = Venta.crear();
  }

  VentaActualState.cargar({
    required Venta venta,
    Articulo? articulo,
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

  Future<Producto?> obtenerProductoPorCodigo(String codigo) async {
    return await consultas.obtenerProductoPorCodigo(CodigoProducto(codigo));
  }

  Future<void> agregarArticulo(Producto producto, double cantidad) async {
    try {
      state.venta.agregarArticulo(Articulo.crear(
        producto: producto,
        cantidad: cantidad,
      ));

      await _guardarVenta();

      // El articulo seleccionado será el último si es nuevo
      // o el que ya exista si tiene el mismo código de producto
      state.articuloSeleccionado = state.venta.articulos.firstWhere((element) =>
          element.producto.codigo == CodigoProducto(producto.codigo).value);
    } on Exception catch (e) {
      // TODO: mostrar mensaje de error o decidir que hacer
      debugPrint(e.toString());
    }

    state = state.copyWith();
  }

  Future<void> agregarVentaRapida(ProductoGenericoDto producto) async {
    final productoGenerico = ProductoGenerico.crear(
      nombre: producto.nombre,
      precioDeVenta: producto.precio,
      impuestos: [],
    );

    state.venta.agregarArticulo(Articulo.crear(
      producto: productoGenerico,
      cantidad: producto.cantidad,
    ));

    await _guardarVenta();
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
    if (state.articuloSeleccionado == null) return;
    // Si es el ultimo articulo, no intentamos avanzar
    if (state.articuloSeleccionado == state.venta.articulos.last) return;

    var indiceArticuloActual =
        state.venta.articulos.indexOf(state.articuloSeleccionado!);

    seleccionarArticulo(state.venta.articulos[indiceArticuloActual + 1]);
  }

  void seleccionarArticuloAnterior() {
    if (state.articuloSeleccionado == null) return;
    // Si es el primer articulo, no intentamos retroceder
    if (state.articuloSeleccionado == state.venta.articulos.first) return;

    var indiceArticuloActual =
        state.venta.articulos.indexOf(state.articuloSeleccionado!);
    seleccionarArticulo(state.venta.articulos[indiceArticuloActual - 1]);
  }

  Future<void> aumentarCantidad() async {
    await _modificarCantidad(1);
  }

  Future<void> disminuirCantidad() async {
    await _modificarCantidad(-1);
  }

  Future<void> _modificarCantidad(double cantidad) async {
    if (state.articuloSeleccionado == null) return;

    final articuloActualizado = state.articuloSeleccionado!
        .copyWith(cantidad: state.articuloSeleccionado!.cantidad + cantidad);
    state.venta.actualizarArticulo(articuloActualizado);

    state = state.copyWith();
    await _guardarVenta();
  }
}

final providerVenta = StateNotifierProvider<NotificadorVenta, VentaActualState>(
    (ref) => NotificadorVenta());
