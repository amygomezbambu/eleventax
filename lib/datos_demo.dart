import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';

import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';

import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';

import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';

import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';

class DatosDemo {
  /// Se encarga de llenar la base de datos con datos de demostración
  /// para un negocio de Abarrotes. Estos datos demo sirven para los screenshots
  /// de las tiendas de apps, pruebas, entre otros.
  Future<void> insertarDatosDemoAbarrotes() async {
    // TODO: Crear unidades de medida demo
    //var unidadPieza = UnidadDeMedida.crear(nombre: 'Pieza', abreviacion: 'pza');
    final unidades = await ModuloProductos.repositorioConsultaProductos()
        .obtenerUnidadesDeMedida();

    await _crearImpuestos();
    await _crearCategorias();
    await _crearProductosPorPieza(unidades.first);
  }

  Future<void> _crearProductosPorPieza(UnidadDeMedida unidadPieza) async {
    // TODO: Sacar estos datos de un JSON o YAML de assets para
    // que sea más fácil de mantener
    final productosDemo = {
      '1': ['Coke Cola 600ml', 12.50],
      '2': ['Gansito Marinela 250mg', 22.50],
      '3': ['Tomate por Kilo', 12.50],
      '4': ['Aguacate Hass', 55.00],
      '5': ['Takis Fuego', 14.70],
      '6': ['Desdodorante Nivea para dama 150ml', 62.20],
      '7': ['Pinguinos Marinela 100mg', 12.50],
    };

    final crearProducto = ModuloProductos.crearProducto();

    for (var codigoProducto in productosDemo.keys) {
      var datosProducto = productosDemo[codigoProducto] as List;

      var nuevoProducto = Producto.crear(
        codigo: CodigoProducto(codigoProducto),
        nombre: NombreProducto(datosProducto[0] as String),
        unidadDeMedida: unidadPieza,
        precioDeCompra:
            PrecioDeCompraProducto(Moneda((datosProducto[1] as double) * 0.80)),
        precioDeVenta:
            PrecioDeVentaProducto(Moneda(datosProducto[1] as double)),
      );

      crearProducto.req.producto = nuevoProducto;
      await crearProducto.exec();
    }

    productosDemo.forEach((codigoProducto, datosProducto) async {});
    // Creamos varios productos
  }

  Future<void> _crearCategorias() async {
    // Creamos varias categorias
    var categorias = ['Refrescos de Cola', 'Frutas y verduras', 'Papelería'];
    for (var nombreCategoria in categorias) {
      var categoria = Categoria.crear(nombre: NombreCategoria(nombreCategoria));
      var crearCategoria = ModuloProductos.crearCategoria();
      crearCategoria.req.categoria = categoria;
      await crearCategoria.exec();
    }
  }

  Future<void> _crearImpuestos() async {
    // TODO: Crear los impuestos por defecto #415
  }
}
