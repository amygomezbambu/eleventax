import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';

abstract class IProducto {
  String get nombre;
  UID get uid;
  String get codigo;
  Moneda get precioDeVenta;
  List<Impuesto> get impuestos;
  Moneda get precioDeVentaSinImpuestos;
  UID get versionActual;
  ProductoSeVendePor get seVendePor;
}
