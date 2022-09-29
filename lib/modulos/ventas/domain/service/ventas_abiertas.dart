import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';

class VentasAbiertas {
  static final List<Venta> _ventas = <Venta>[];

  VentasAbiertas();

  static void agregar(Venta sale) {
    _ventas.add(sale);
  }

  static void eliminar(String uid) {
    var ventaARemover =
        _ventas.firstWhere((sale) => sale.uid.toString() == uid);

    _ventas.remove(ventaARemover);
  }

  static Venta obtener(String uid) {
    return _ventas.firstWhere((sale) => sale.uid.toString() == uid);
  }
}
