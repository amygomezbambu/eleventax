import 'package:eleventa/modulos/ventas/app/dto/articulo_de_venta.dart';
import 'package:eleventa/modulos/ventas/app/dto/venta_dto.dart';
import 'package:eleventa/modulos/ventas/app/mapper/mapper_articulo.dart';
import 'package:eleventa/modulos/ventas/domain/entity/venta.dart';

class VentaMapper {
  static VentaDTO fromDomainToDTO(Venta venta) {
    var dto = VentaDTO();
    dto.name = venta.nombre;
    dto.total = venta.total;
    dto.uid = venta.uid.toString();
    dto.metodoDePago = venta.metodoDePago;
    dto.fechaDePago = venta.fechaDePago;
    dto.status = venta.status;

    dto.articulos = <ArticuloDTO>[];

    for (var articulo in venta.articulos) {
      dto.articulos.add(ArticuloMapper.dominioAData(articulo));
    }

    return dto;
  }
}
