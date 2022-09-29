import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/domain/service/ventas_abiertas.dart';

class CobrarVentaReq {
  late MetodoDePago metodoDePago;
  late String ventaUID;
}

class CobrarVenta extends Usecase<void> {
  final req = CobrarVentaReq();
  final IRepositorioDeVentas _repo;

  CobrarVenta(this._repo) : super(_repo) {
    operation = _operation;
  }

  Future<void> _operation() async {
    var sale = VentasAbiertas.obtener(req.ventaUID);

    sale.cobrar(req.metodoDePago);

    await _repo.actualizarDatosDePago(sale);
  }
}
