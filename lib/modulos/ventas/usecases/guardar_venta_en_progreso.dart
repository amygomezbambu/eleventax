import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/ventas_ex.dart';

class GuardarVentaEnProgresoRequest {
  late Venta venta;
}

class GuardarVentaEnProgreso extends Usecase<void> {
  var req = GuardarVentaEnProgresoRequest();
  final IRepositorioVentas _ventas;
  final IRepositorioConsultaVentas _consultas;

  GuardarVentaEnProgreso(
      IRepositorioVentas ventas, IRepositorioConsultaVentas consultas)
      : _ventas = ventas,
        _consultas = consultas,
        super(ventas) {
    operation = _operation;
  }

  Future<void> _operation() async {
    if (req.venta.estado != EstadoDeVenta.enProgreso) {
      throw VentasEx(
        tipo: TiposVentasEx.pagosInsuficientes,
        message: 'Solo se puede almacenar una venta en progreso',
        input: req.venta.uid.toString(),
      );
    }

    if (await _consultas.obtenerVentaEnProgreso(req.venta.uid) != null) {
      await _ventas.modificarVentaEnProgreso(req.venta);
    } else {
      await _ventas.agregarVentaEnProgreso(req.venta);
    }
  }
}
