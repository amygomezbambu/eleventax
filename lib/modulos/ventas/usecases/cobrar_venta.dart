import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/ventas/domain/venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/ventas_ex.dart';

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

  //TODO: cambiar message por debugMessage y usar mensajes para debug
  //eliminar las excepciones(Tipos) que ya no se usan (como DomainEx)
  Future<void> _operation() async {
    if (req.venta.estado == EstadoDeVenta.cobrada) {
      throw VentasEx(
          tipo: TiposVentasEx.ventaYaCobrada,
          message: 'No es posible guardar una venta ya cobrada',
          input: req.venta.uid.toString());
    }

    if (req.venta.total == Moneda(0)) {
      throw ValidationEx(
        tipo: TipoValidationEx.valorEnCero,
        mensaje: 'No se puede cobrar una venta en ceros',
      );
    }

    if (req.venta.totalPagos != req.venta.total) {
      throw VentasEx(
          tipo: TiposVentasEx.pagosInsuficientes,
          message:
              'El monto de los pagos recibidos difiere del total de la venta',
          input: req.venta.uid.toString());
    }

    req.venta.marcarComoCobrada();

    await _ventas.agregar(req.venta);

    //TODO: eliminar los registros del Queue de ventas en progreso
  }
}
