import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

class ProductoGenericoDto {
  final NombreProducto nombre;
  final double cantidad;
  final PrecioDeVentaProducto precio;

  ProductoGenericoDto({
    required this.nombre,
    required this.cantidad,
    required this.precio,
  });
}
