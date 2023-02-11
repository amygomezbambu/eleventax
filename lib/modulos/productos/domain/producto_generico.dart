import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

class ProductoGenerico implements IProducto {
  final NombreProducto _nombre;
  final List<Impuesto> _impuestos;
  final PrecioDeVentaProducto _precioDeVenta;
  final UID _uid;
  final CodigoProducto _codigo;

  @override
  UID get uid => _uid;

  @override
  List<Impuesto> get impuestos => List.unmodifiable(_impuestos);
  @override
  String get nombre => _nombre.value;
  @override
  String get codigo => _codigo.value;
  @override
  Moneda get precioDeVenta => _precioDeVenta.value;
  @override
  Moneda get precioDeVentaSinImpuestos {
    var precioSinImpuestos = _precioDeVenta.value.toDouble();

    //_impuestos es final porlo que no se le puede hacer sort directamente
    var impuestosCopy = [..._impuestos];

    impuestosCopy.sort((a, b) => b.ordenDeAplicacion.compareTo(
          a.ordenDeAplicacion,
        ));

    for (var impuesto in impuestosCopy) {
      var montoImpuesto = precioSinImpuestos -
          (precioSinImpuestos / (1 + (impuesto.porcentaje / 100)));

      precioSinImpuestos -= montoImpuesto;
    }

    return Moneda(precioSinImpuestos);
  }

  ProductoGenerico.crear({
    required NombreProducto nombre,
    List<Impuesto> impuestos = const [],
    required PrecioDeVentaProducto precioDeVenta,
  })  : _nombre = nombre,
        _impuestos = impuestos,
        _precioDeVenta = precioDeVenta,
        _uid = UID(),
        _codigo = CodigoProducto('generico');
}
