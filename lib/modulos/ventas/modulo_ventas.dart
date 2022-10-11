import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/ventas/app/usecase/agregar_articulo.dart';
import 'package:eleventa/modulos/ventas/app/usecase/cobrar_venta.dart';
import 'package:eleventa/modulos/ventas/app/usecase/crear_venta.dart';
import 'package:eleventa/modulos/ventas/app/usecase/obtener_venta.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';

class ModuloVentas {
  static final config = ConfigVentas(Dependencias.ventas.repositorioVentas());

  static AgregarArticulo agregarArticulo() {
    return AgregarArticulo(Dependencias.ventas.repositorioVentas());
  }

  static CrearVenta crearVenta() {
    return CrearVenta();
  }

  static CobrarVenta cobrarVenta() {
    return CobrarVenta(Dependencias.ventas.repositorioVentas());
  }

  static ObtenerVenta obtenerVenta() {
    return ObtenerVenta(Dependencias.ventas.repositorioVentas());
  }
}
