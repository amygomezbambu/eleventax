import 'package:eleventa/modulos/common/app/usecase/usecase.dart';

class ObtenerVentasEnProgreso {}

class GuardarVenta extends Usecase<void> {
  // var req = GuardarVentaRequest();
  // final IRepositorioVentas _ventas;
  // final IRepositorioConsultaVentas _consultas;

  // GuardarVenta(IRepositorioVentas ventas, IRepositorioConsultaVentas consultas)
  //     : _ventas = ventas,
  //       _consultas = consultas,
  //       super(ventas) {
  //   operation = _operation;
  // }

  // Future<void> _operation() async {
  //   //TODO: validar si es venta cobrada, no guardar.

  //   if (await _consultas.obtenerVenta(req.venta.uid) != null) {
  //     await _ventas.modificar(req.venta);
  //   } else {
  //     await _ventas.agregar(req.venta);
  //   }
  // }
}
