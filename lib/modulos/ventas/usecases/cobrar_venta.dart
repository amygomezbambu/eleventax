import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';

class CobrarVentaRequest {
  late Venta venta;
}

class CobrarVenta extends Usecase<void> {
  var req = CobrarVentaRequest();
  final IRepositorioVentas _ventas;

  CobrarVenta(IRepositorioVentas ventas)
      : _ventas = ventas,
        super(ventas) {
    operation = _operation;
  }

  Future<void> _operation() async {
    if (req.venta.estado == EstadoDeVenta.cobrada) {
      throw AppEx(
          message: 'No es posible guardar una venta ya cobrada',
          input: req.venta.uid.toString());
    }

    req.venta.cobrar();

    await _ventas.agregar(req.venta);

    //TODO: eliminar los registros del Queue de ventas en progreso
  }
}
