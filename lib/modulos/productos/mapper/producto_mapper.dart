import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';

import 'package:eleventa/modulos/common/domain/moneda.dart';

class ProductoMapper {
  // static ProductoDTO domainAData(Producto producto) {
  //   var dto = ProductoDTO();
  //   // dto.descripcion = producto.descripcion;
  //   // dto.precio = producto.precio;
  //   // dto.sku = producto.sku;
  //   // dto.uid = producto.uid.toString();

  //   return dto;
  // }

  static Map<String, Object?> domainAMap(Producto producto) {
    return <String, Object?>{
      'uid': producto.uid.toString(),
      'codigo': producto.codigo,
      'nombre': producto.nombre,
      'categoria': producto.categoria,
      'precio_compra': producto.precioDeCompra,
      'precio_venta': producto.precioDeVenta,
      'se_vende_por': producto.seVendePor.index,
      'url_imagen': producto.imagenURL,
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
      uid: UID(dbRow['uid'] as String),
      nombre: dbRow['nombre'] as String,
      precioDeVenta: Moneda(dbRow['precio_venta'] as int),
      precioDeCompra: Moneda(dbRow['precio_compra'] as int),
      codigo: dbRow['codigo'] as String,
    );
  }
}
