import 'package:eleventa/modulos/common/app/interface/repositorio.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';

abstract class IRepositorioVentas extends IRepositorio<Venta> {
  Future<void> agregarVentaEnProgreso(Venta venta);
  Future<void> eliminarVentaEnProgreso(UID uid);
  Future<void> modificarVentaEnProgreso(Venta venta);
}
