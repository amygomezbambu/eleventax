import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';

abstract class IRepositorioConsultaVentas {
  Future<Venta?> obtenerVenta(UID uid);
  Future<Venta?> obtenerVentaEnProgreso(UID uid);
}
