import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/app/dto/articulo_de_venta.dart';
import 'package:eleventa/modulos/ventas/domain/entity/articulo_de_venta.dart';

class ArticuloMapper {
  static ArticuloDeVenta dataADominio(ArticuloDTO articulo) {
    return ArticuloDeVenta(
      productoUID:
          articulo.productoUID != null ? UID(articulo.productoUID!) : null,
      ventaUID: UID(articulo.ventaUID),
      descripcion: articulo.descripcion,
      precio: articulo.precio,
      cantidad: articulo.cantidad,
    );
  }

  static ArticuloDTO dominioAData(ArticuloDeVenta articulo) {
    var dto = ArticuloDTO();

    dto.ventaUID = articulo.ventaUID.toString();
    dto.productoUID = articulo.productoUID?.toString();
    dto.precio = articulo.precio;
    dto.cantidad = articulo.cantidad;

    return dto;
  }
}
