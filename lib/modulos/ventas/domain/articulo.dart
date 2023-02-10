import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';

class Articulo extends Entidad {
  Producto? _producto;
  var _cantidad = 0.00;
  var _subtotal = Moneda(0);
  final DateTime _agregadoEn;
  late NombreProducto _descripcion;
  var _precioDeVenta = Moneda(0);
  final List<TotalDeImpuesto> _totalesDeImpuestos;

  double get cantidad => _cantidad;
  Moneda get subtotal => _subtotal;
  Moneda get total => _subtotal + totalImpuestos;
  Moneda get precioDeVenta => _precioDeVenta;
  DateTime get agregadoEn => _agregadoEn;
  String get descripcion => _descripcion.value;
  Producto? get producto => _producto;

  List<TotalDeImpuesto> get totalesDeImpuestos =>
      List.unmodifiable(_totalesDeImpuestos);

  Moneda get totalImpuestos {
    var resultado = Moneda(0.00);
    for (var totalDeImpuesto in _totalesDeImpuestos) {
      resultado += totalDeImpuesto.monto;
    }

    return resultado;
  }

  Articulo.cargar({
    required UID uid,
    required double cantidad,
    required DateTime agregadoEn,
    required NombreProducto descripcion,
    required Producto producto,
  })  : _cantidad = cantidad,
        _agregadoEn = agregadoEn,
        _descripcion = descripcion,
        _producto = producto,
        _totalesDeImpuestos = [],
        super.cargar(uid) {
    //TODO: validar que el precio de venta no sea cero, en este punto no debe
    //ser cero nunca
    _precioDeVenta = producto.precioDeVenta!;
    _calcularTotales();
  }

  Articulo.crear({
    required Producto producto,
    required double cantidad,
  })  : _cantidad = cantidad,
        _agregadoEn = DateTime.now(),
        _producto = producto,
        _totalesDeImpuestos = [],
        super.crear() {
    _descripcion = NombreProducto(producto.nombre);
    _precioDeVenta = producto.precioDeVenta!;
    _calcularTotales();
  }

  Articulo.crearDesdeProductoGenerico({
    required NombreProducto descripcion,
    required double cantidad,
    required Moneda precioDeVenta,
  })  : _descripcion = descripcion,
        _precioDeVenta = precioDeVenta,
        _cantidad = cantidad,
        _agregadoEn = DateTime.now(),
        _totalesDeImpuestos = [],
        super.crear() {
    _calcularTotales();
  }

  void actualizarCantidad(double cantidad) {
    _cantidad = cantidad;
    _calcularTotales();
  }

  //TODO: mover logica a venta
  Moneda _obtenerPrecioSinImpuestos() {
    //Map<String, Moneda> totalesPorImpuesto = {};

    return Moneda(_producto!.precioDeVentaSinImpuestos.toDouble() * _cantidad);

    // var precioSinImpuestos =
    //     Moneda(_producto!.precioDeVentaSinImpuestos.toDouble() * _cantidad)
    //         .redondearADecimales(3);

    // if (_producto == null || _producto!.impuestos.isEmpty) {
    //   return precioSinImpuestos;
    // }

    // final montoObjetivo =
    //     Moneda(producto!.precioDeVenta!.toDouble() * _cantidad);

    // var salir = false;

    // // 1. Ordenamos los impuestos en base al orden de aplicación
    // // para tomar como base para el IVA el precio mas IEPS por ejemplo
    // final impuestosDescendentes = [..._producto!.impuestos];

    // impuestosDescendentes
    //     .sort((a, b) => a.ordenDeAplicacion.compareTo(b.ordenDeAplicacion));

    // //Para forzar que sea una nueva referencia hacemos lo siguiente:
    // var baseDelImpuesto = Moneda(precioSinImpuestos.toDouble());

    // //redondear precio sin impuestos a 4 decimales redondeando
    // //19485.153247  -> 19485.154000 -> 19485.155000 -> 19485.156000 -> hasta encontrar valor

    // var contador = 1;

    // while (salir != true) {
    //   if (contador == 19) {
    //     break;
    //   }

    //   for (var impuesto in impuestosDescendentes) {
    //     final montoDeImpuesto =
    //         baseDelImpuesto.toDouble() * (impuesto.porcentaje / 100);

    //     totalesPorImpuesto[impuesto.nombre] = Moneda(montoDeImpuesto);

    //     baseDelImpuesto += Moneda(montoDeImpuesto);
    //   }

    //   var totalADosDecimales = precioSinImpuestos.importeCobrable;

    //   for (var importe in totalesPorImpuesto.values) {
    //     totalADosDecimales += importe.importeCobrable;
    //   }

    //   if (totalADosDecimales.importeCobrable == montoObjetivo.importeCobrable) {
    //     salir = true;
    //     print("Valor encontrado: ${precioSinImpuestos.toDouble().toString()}");
    //   } else {
    //     precioSinImpuestos = totalADosDecimales < montoObjetivo
    //         ? precioSinImpuestos + Moneda(0.001)
    //         : precioSinImpuestos - Moneda(0.001);

    //     baseDelImpuesto = Moneda(precioSinImpuestos.toDouble());
    //     totalesPorImpuesto = {};
    //   }

    //   contador++;
    // }

    //return precioSinImpuestos;
  }

  void _calcularTotales() {
    if (_producto != null) {
      _subtotal = _obtenerPrecioSinImpuestos();

      var baseDelImpuesto = _subtotal;

      var impuestosDescendentes = [..._producto!.impuestos];
      impuestosDescendentes
          .sort((a, b) => a.ordenDeAplicacion.compareTo(b.ordenDeAplicacion));

      _totalesDeImpuestos.clear();

      for (var impuesto in impuestosDescendentes) {
        // TODO: Ver cómo multiplicar facilmente Moneda x double
        final montoDeImpuesto =
            baseDelImpuesto.toDouble() * (impuesto.porcentaje / 100);

        TotalDeImpuesto totalDeImpuesto = TotalDeImpuesto(
            base: baseDelImpuesto,
            monto: Moneda(montoDeImpuesto),
            impuesto: impuesto);

        _totalesDeImpuestos.add(totalDeImpuesto);

        baseDelImpuesto += Moneda(montoDeImpuesto);
      }
    } else {
      // TODO: Implementar cálculo de impuestos con genericos
    }
  }
}
