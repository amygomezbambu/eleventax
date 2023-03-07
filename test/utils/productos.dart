import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:faker/faker.dart';

class ProductosUtils {
  static Producto crearProducto({
    String? codigo,
    String? nombre,
    Moneda? precioCompra,
    Moneda? precioVenta,
    Categoria? categoria,
    UnidadDeMedida? unidadDeMedida,
    ProductoSeVendePor productoSeVendePor = ProductoSeVendePor.unidad,
    List<Impuesto>? impuestos,
  }) {
    var faker = Faker();

    final categoria_ = categoria ??
        Categoria.crear(
          nombre: NombreCategoria.sinCategoria(),
        );

    final codigo_ = codigo != null
        ? CodigoProducto(codigo)
        : CodigoProducto(UID().toString());

    final nombre_ = nombre != null
        ? NombreProducto(nombre)
        : NombreProducto(faker.food.dish());

    final precioCompra_ = precioCompra != null
        ? PrecioDeCompraProducto(precioCompra)
        : PrecioDeCompraProducto(Moneda(faker.randomGenerator.decimal(min: 1)));

    final precioVenta_ = precioVenta != null
        ? PrecioDeVentaProducto(precioVenta)
        : PrecioDeVentaProducto(Moneda(faker.randomGenerator.decimal(min: 5)));

    final unidadDeMedida_ = unidadDeMedida ??
        UnidadDeMedida.crear(
          nombre: 'pieza',
          abreviacion: 'pza',
        );
    final impuestos_ = impuestos ??
        <Impuesto>[
          Impuesto.crear(
              nombre: 'IVA',
              porcentaje: PorcentajeDeImpuesto(16.0),
              ordenDeAplicacion: 2),
        ];

    return Producto.crear(
      codigo: codigo_,
      nombre: nombre_,
      unidadDeMedida: unidadDeMedida_,
      precioDeCompra: precioCompra_,
      precioDeVenta: precioVenta_,
      categoria: categoria_,
      impuestos: impuestos_,
      seVendePor: productoSeVendePor,
    );
  }
}
