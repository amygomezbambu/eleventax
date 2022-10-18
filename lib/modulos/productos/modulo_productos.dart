import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/app/usecase/obtener_producto.dart';
import 'package:eleventa/modulos/productos/app/usecase/obtener_productos.dart';
import 'package:eleventa/modulos/productos/app/usecase/actualizar_producto.dart';
import 'package:eleventa/modulos/productos/usecases/crear_producto/crear_producto.dart';

class ModuloProductos {
  // static ObtenerProducto obtenerProducto() {
  //   return ObtenerProducto(Dependencias.ventas.repositorioArticulos());
  // }

  // static ObtenerProductos obtenerProductos() {
  //   return ObtenerProductos(Dependencias.ventas.repositorioArticulos());
  // }

  static CrearProducto crearProducto() {
    return CrearProducto(Dependencias.productos.repositorioProductos());
  }

  static ActualizarProducto actualizarProducto() {
    return ActualizarProducto(Dependencias.ventas.repositorioArticulos());
  }
}
