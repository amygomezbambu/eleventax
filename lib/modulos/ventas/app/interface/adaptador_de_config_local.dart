import 'package:eleventa/modulos/ventas/config_ventas.dart';

abstract class IAdaptadorDeConfigLocalDeVentas {
  Future<void> guardar(ConfigLocalDeVentas config);
  Future<ConfigLocalDeVentas> leer();
}
