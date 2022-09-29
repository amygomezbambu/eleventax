import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/app/dto/producto_dto.dart';
import 'package:eleventa/modulos/productos/domain/entity/producto.dart';

class ProductoMapper {
  static ProductoDTO domainAData(Producto producto) {
    var dto = ProductoDTO();
    dto.descripcion = producto.descripcion;
    dto.precio = producto.precio;
    dto.sku = producto.sku;
    dto.uid = producto.uid.toString();

    return dto;
  }

  static Map<String, Object?> domainAMap(Producto producto) {
    return <String, Object?>{
      'uid': producto.uid.toString(),
      'descripcion': producto.descripcion,
      'precio': producto.precio,
      'sku': producto.sku
    };
  }

  /// Convierte un row de sqlite a una entidad de dominio
  ///
  /// ***IMPORTANTE*** esta implementación esta acoplada a SQLite y al paquete
  /// [Sqflite], si se decide desacoplar el mapeador, tendriamos que crear uno
  /// exclusivo para la base de datos que estuviera incluido en la implementación,
  /// de esa manera al cambiar la db cambiaria automaticamente el mapeador.
  static Producto databaseADomain(Map<String, Object?> dbRow) {
    return Producto.cargar(
      UID(dbRow['uid'] as String),
      dbRow['sku'] as String,
      dbRow['descripcion'] as String,
      dbRow['precio'] as double,
    );
  }
}
