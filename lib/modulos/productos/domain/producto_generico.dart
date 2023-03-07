import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/interface/producto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/servicio/calcular_precio_sin_impuesto_de_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

class ProductoGenerico extends Entidad implements IProducto {
  final NombreProducto _nombre;
  final List<Impuesto> _impuestos;
  final PrecioDeVentaProducto _precioDeVenta;
  final UID _uid;
  final CodigoProducto _codigo = CodigoProducto.generico();
  final ProductoSeVendePor _seVendePor = ProductoSeVendePor.peso;

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
  Moneda get precioDeVentaSinImpuestos =>
      calcularPrecioSinImpuestos(_precioDeVenta, _impuestos);
  @override
  UID get versionActual => UID.invalid();

  @override
  ProductoSeVendePor get seVendePor => _seVendePor;

  ProductoGenerico.crear({
    required NombreProducto nombre,
    List<Impuesto> impuestos = const [],
    required PrecioDeVentaProducto precioDeVenta,
  })  : _nombre = nombre,
        _impuestos = impuestos,
        _precioDeVenta = precioDeVenta,
        _uid = UID(),
        super.crear();

  ProductoGenerico.cargar(
      {required NombreProducto nombre,
      List<Impuesto> impuestos = const [],
      required PrecioDeVentaProducto precioDeVenta,
      required UID uid})
      : _nombre = nombre,
        _impuestos = impuestos,
        _precioDeVenta = precioDeVenta,
        _uid = uid,
        super.cargar(uid);

  @override
  String toString() {
    return 'ProductoGenerico{_nombre: $_nombre, _impuestos: $_impuestos, _precioDeVenta: $_precioDeVenta, _uid: $_uid, _codigo: $_codigo, _seVendePor: $_seVendePor}';
  }
}
