import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_productos_lectura.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos_lectura.dart';
import 'package:eleventa/modulos/productos/usecases/actualizar_producto.dart';
import 'package:eleventa/modulos/productos/usecases/crear_producto.dart';
import 'package:eleventa/modulos/productos/usecases/obtener_producto.dart';
import 'package:eleventa/modulos/productos/usecases/obtener_productos.dart';

class ModuloProductos {
  static ObtenerProducto obtenerProducto() {
    return ObtenerProducto(Dependencias.productos.repositorioProductos());
  }

  static ObtenerProductos obtenerProductos() {
    return ObtenerProductos(Dependencias.productos.repositorioProductos());
  }

  static CrearProducto crearProducto() {
    return CrearProducto(Dependencias.productos.repositorioProductos());
  }

  static ActualizarProducto actualizarProducto() {
    return ActualizarProducto(Dependencias.productos.repositorioProductos());
  }

  static RepositorioLecturaProductos repositorioLecturaProductos() {
    return RepositorioLecturaProductos(db: Dependencias.infra.database());
  }
}
