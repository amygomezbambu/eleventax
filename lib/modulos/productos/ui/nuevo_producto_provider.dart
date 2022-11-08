//estado base
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class EstadoNuevoProducto {
  CodigoProducto? codigo;
  NombreProducto? nombre;
  PrecioDeVentaProducto? precioDeVenta;
  var precioDeCompra = PrecioDeCompraProducto(Moneda(0));
  var urlImagen = '';
  var seVendePor = ProductoSeVendePor.unidad;
  late Categoria categoria;
  late Impuesto impuesto;
  late UnidadDeMedida unidadDeMedida;
  bool preguntarPrecio = true;
  double _utilidad = 0.0;
  bool existeCodigo = false;
}

//estado inicial
class EstadoInicialNuevoProducto extends EstadoNuevoProducto {
  EstadoInicialNuevoProducto({required double utilidad}) : super() {
    _utilidad = utilidad;
    codigo = null;
    nombre = null;
    precioDeVenta = null;
    precioDeCompra = PrecioDeCompraProducto(Moneda(0));
    urlImagen = '';
    seVendePor = ProductoSeVendePor.unidad;
    preguntarPrecio = true;
    existeCodigo = false;
  }

  static EstadoInicialNuevoProducto copyWith(EstadoNuevoProducto actual) {
    var instancia = EstadoInicialNuevoProducto(utilidad: 10.00);
    instancia.codigo = actual.codigo;
    instancia.nombre = actual.nombre;
    instancia.categoria = actual.categoria;
    instancia.impuesto = actual.impuesto;
    instancia.precioDeCompra = actual.precioDeCompra;
    instancia.precioDeVenta = actual.precioDeVenta;
    instancia.preguntarPrecio = actual.preguntarPrecio;
    instancia.seVendePor = actual.seVendePor;
    instancia.existeCodigo = actual.existeCodigo;
    instancia._utilidad = actual._utilidad;

    return instancia;
  }
}

//estado de cargando
class EstadoCargandoNuevoProducto extends EstadoNuevoProducto {
  EstadoCargandoNuevoProducto() : super();
}

//estado de exito o finalizacion
class EstadoExitoNuevoProducto extends EstadoNuevoProducto {
  EstadoExitoNuevoProducto() : super();
}

//estado de error
class EstadoErrorNuevoProducto extends EstadoNuevoProducto {
  String message;

  EstadoErrorNuevoProducto(this.message) : super();
}

class NotificadorNuevoProducto extends StateNotifier<EstadoNuevoProducto> {
  CodigoProducto? get codigo => state.codigo;

  NotificadorNuevoProducto()
      : super(EstadoInicialNuevoProducto(utilidad: 10.0));

  Future<void> crearProducto() async {
    var crearProducto = ModuloProductos.crearProducto();

    // bool hayPrecioDeVenta = _controllerPrecioDeVenta.text.isNotEmpty;
    // PrecioDeVentaProducto? precioDeVenta;

    // if (hayPrecioDeVenta) {
    //   precioDeVenta =
    //       PrecioDeVentaProducto(Moneda(_controllerPrecioDeVenta.text));
    // }

    try {
      if (state.codigo != null && state.nombre != null) {
        var producto = Producto.crear(
          codigo: state.codigo!,
          nombre: state.nombre!,
          precioDeCompra: state.precioDeCompra,
          seVendePor: state.seVendePor,
          categoria: state.categoria,
          impuestos: [state.impuesto],
          unidadDeMedida: state.unidadDeMedida,
          preguntarPrecio: state.precioDeVenta == null,
          precioDeVenta: state.precioDeVenta,
        );

        crearProducto.req.producto = producto;

        state = EstadoCargandoNuevoProducto();

        await crearProducto.exec();

        state = EstadoExitoNuevoProducto();
      }
    } catch (e) {
      state = EstadoErrorNuevoProducto(e.toString());
    }
  }

  void limpiar() {
    state = EstadoInicialNuevoProducto(utilidad: 10.00);
  }

  Future<void> sanitizarYValidarCodigo(String codigo) async {
    try {
      var codigoProducto = CodigoProducto(codigo);
      await _verificarExistenciaDeCodigo(codigo);

      if (!state.existeCodigo) {
        state.codigo = codigoProducto;
      }
    } catch (e) {
      state = EstadoErrorNuevoProducto(e.toString());
    }
  }

  void sanitizarYValidarNombre(String nombre) {
    try {
      state.nombre = NombreProducto(nombre);
    } catch (e) {
      state = EstadoErrorNuevoProducto(e.toString());
    }
  }

  Future<void> _verificarExistenciaDeCodigo(String codigo) async {
    var consultas = ModuloProductos.repositorioConsultaProductos();

    state.existeCodigo = await consultas.existeProducto(codigo);

    if (state.existeCodigo) {
      state = EstadoInicialNuevoProducto.copyWith(state);
    }
  }
}

final nuevoProductoProvider =
    StateNotifierProvider<NotificadorNuevoProducto, EstadoNuevoProducto>(
        (ref) => NotificadorNuevoProducto());
