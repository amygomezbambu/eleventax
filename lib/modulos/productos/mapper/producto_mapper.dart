import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

class ProductoMapper {
  // static ProductoDTO domainAData(Producto producto) {
  //   var dto = ProductoDTO();
  //   // dto.descripcion = producto.descripcion;
  //   // dto.precio = producto.precio;
  //   // dto.sku = producto.sku;
  //   // dto.uid = producto.uid.toString();

  //   return dto;
  // }

  //TODO: Reflection o instrospeccion
  //TODO: Solo aceptar tipos primitivos y Moneda
  static Map<String, Object?> domainAMap(Producto producto) {
    return <String, Object?>{
      'uid': producto.uid.toString(),
      'codigo': producto.codigo,
      'nombre': producto.nombre,
      'categoria_uid': producto.categoria?.uid.toString(),
      'precio_compra': producto.precioDeCompra,
      'precio_venta': producto.precioDeVenta,
      'se_vende_por': producto.seVendePor.index,
      'unidad_medida_uid': producto.unidadMedida.uid.toString(),
      'url_imagen': producto.imagenURL,
      //'impuestos': producto.impuestos,
      'preguntar_precio': producto.preguntarPrecio,
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
      uid: UID.fromString(dbRow['uid'] as String),
      nombre: NombreProducto(dbRow['nombre'] as String),
      precioDeVenta: PrecioDeVentaProducto(
          Moneda.fromMonedaInt(dbRow['precio_venta'] as int)),
      precioDeCompra: PrecioDeCompraProducto(
          Moneda.fromMonedaInt(dbRow['precio_compra'] as int)),
      codigo: CodigoProducto(dbRow['codigo'] as String),
      unidadDeMedida: UnidadDeMedida.cargar(
          uid: UID.fromString(dbRow['unidad_medida_uid'] as String),
          nombre: dbRow['unidad_medida_nombre'] as String,
          abreviacion: dbRow['unidad_medida_abreviacion'] as String),
      preguntarPrecio: Utils.db.intToBool(dbRow['preguntar_precio'] as int),
      imagenURL: dbRow['url_imagen'] as String,
    );
  }
}
