import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/config_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/usecases/eliminar_producto.dart';
import 'package:eleventa/modulos/productos/usecases/modificar_producto.dart';
import 'package:eleventa/modulos/productos/usecases/crear_producto.dart';

class ModuloProductos {
  static final config =
      ConfigProductos(Dependencias.productos.repositorioProductos());

  static CrearProducto crearProducto() {
    return CrearProducto(Dependencias.productos.repositorioProductos(),
        Dependencias.productos.repositorioConsultasProductos());
  }

  static ModificarProducto modificarProducto() {
    return ModificarProducto(Dependencias.productos.repositorioProductos());
  }

  static EliminarProducto eliminarProducto() {
    return EliminarProducto(Dependencias.productos.repositorioProductos());
  }

  static IRepositorioConsultaProductos repositorioConsultaProductos() {
    return Dependencias.productos.repositorioConsultasProductos();
  }
}
