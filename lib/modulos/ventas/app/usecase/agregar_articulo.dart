import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/app/dto/venta_dto.dart';
import 'package:eleventa/modulos/ventas/app/dto/articulo_de_venta.dart';
import 'package:eleventa/modulos/ventas/app/interface/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/app/mapper/mapper_articulo.dart';
import 'package:eleventa/modulos/ventas/app/mapper/mapper_venta.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';
import 'package:eleventa/modulos/ventas/domain/service/ventas_abiertas.dart';

class AgregarArticuloReq {
  var ventaUID = '';
  var articulo = ArticuloDTO();
}

class AgregarArticulo extends Usecase<VentaDTO> {
  var req = AgregarArticuloReq();
  final IRepositorioDeVentas _repo;

  AgregarArticulo(this._repo) : super(_repo) {
    operation = _operation;
  }

  /// Ejecuta el caso de uso
  ///
  /// Retorna los datos actualizados de la venta o una excepción en caso de que no exista la venta
  Future<VentaDTO> _operation() async {
    Venta venta;

    venta = VentasAbiertas.obtener(req.ventaUID);

    var articulo = ArticuloMapper.dataADominio(req.articulo);

    venta.agregarArticulo(articulo);

    if (await existeVenta(venta.uid)) {
      await _repo.modificar(venta);
    } else {
      await _repo.agregar(venta);
    }

    await _repo.agregarArticuloDeVenta(articulo);

    return VentaMapper.fromDomainToDTO(venta);
  }

  Future<bool> existeVenta(UID uid) async {
    //var venta = await _repo.obtener(uid);

    //return (venta != null ? true : false);

    return false;
  }
}
