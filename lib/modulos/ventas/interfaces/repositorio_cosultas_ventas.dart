import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';

abstract class IRepositorioConsultaVentas {
  Future<VentaDto?> obtenerVenta(UID uid);
  Future<List<VentaDto>> obtenerHistoricoVentas(DateTime fechaReporte);
  Future<List<FormaDePago>> obtenerFormasDePago();
  Future<FormaDePago?> obtenerFormaDePago(UID uid);
  Future<Venta?> obtenerVentaEnProgreso(UID uid);
  Future<String?> obtenerFolioDeVentaMasReciente();
}
