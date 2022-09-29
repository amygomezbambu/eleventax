import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/domain/service/ventas_abiertas.dart';

class CrearVentaReq {
  int cajeroUID = 0;
  int dispositivoUID = 0;
}

class CrearVenta {
  final request = CrearVentaReq();

  String exec() {
    Venta venta;

    try {
      venta = Venta.crear();
      VentasAbiertas.agregar(venta);
    } catch (e) {
      rethrow;
    }

    return venta.uid.toString();
  }
}
