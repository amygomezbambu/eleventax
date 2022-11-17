import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/usecases/actualizar_producto.dart';
import 'package:eleventa/modulos/productos/usecases/crear_producto.dart';
import 'package:eleventa/modulos/productos/usecases/obtener_productos.dart';

class ModuloProductos {
  static final config =
      ConfigProductos(Dependencias.productos.repositorioProductos());
  static ObtenerProductos obtenerProductos() {
    return ObtenerProductos(Dependencias.productos.repositorioProductos());
  }

  static CrearProducto crearProducto() {
    return CrearProducto(Dependencias.productos.repositorioProductos(),
        Dependencias.productos.repositorioConsultasProductos());
  }

  static ActualizarProducto actualizarProducto() {
    return ActualizarProducto(Dependencias.productos.repositorioProductos());
  }

  static IRepositorioConsultaProductos repositorioConsultaProductos() {
    return Dependencias.productos.repositorioConsultasProductos();
  }
}
