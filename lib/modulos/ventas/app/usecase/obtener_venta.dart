import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/ventas/app/dto/venta_dto.dart';

class ObtenerVentaReq {
  String ventaUID = '';
}

class ObtenerVenta extends Usecase<VentaDTO> {
  var req = ObtenerVentaReq();
  // final IRepositorioDeVentas _repo;

  // ObtenerVenta(this._repo) : super(_repo) {
  //   operation = _operation;
  // }

  // Future<VentaDTO> _operation() async {
  //   // var venta = await _repo.obtener(UID.fromString(req.ventaUID));

  //   // if (venta == null) {
  //   //   throw Exception('No existe la venta');
  //   // }

  //   // var dto = VentaMapper.fromDomainToDTO(venta);

  //   // return dto;
  //   throw Exception('no implementado');
  // }
}
