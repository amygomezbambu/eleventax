import 'package:eleventa/modulos/common/app/interface/repositorio.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/domain/entity/articulo_de_venta.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';

abstract class IRepositorioDeVentas extends IRepositorio<Venta> {
  Future<void> agregarArticuloDeVenta(ArticuloDeVenta item);
  Future<void> actualizarDatosDePago(Venta sale);
  Future<void> guardarConfigCompartida(ConfigCompartidaDeVentas config);
  Future<ConfigCompartidaDeVentas> obtenerConfigCompartida();
}
