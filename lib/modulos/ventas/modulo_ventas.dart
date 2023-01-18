import 'package:eleventa/dependencias.dart';
// import 'package:eleventa/modulos/ventas/app/usecase/agregar_articulo.dart';
// import 'package:eleventa/modulos/ventas/app/usecase/cobrar_venta.dart';
// import 'package:eleventa/modulos/ventas/app/usecase/crear_venta.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/usecases/guardar_venta.dart';

class ModuloVentas {
  //static final config = ConfigVentas(Dependencias.ventas.repositorioVentas());

  static GuardarVenta guardarVenta() {
    return GuardarVenta(Dependencias.ventas.repositorioVentas(),
        Dependencias.ventas.repositorioConsultasVentas());
  }

  static IRepositorioConsultaVentas repositorioConsultaVentas() {
    return Dependencias.ventas.repositorioConsultasVentas();
  }

  // static AgregarArticulo agregarArticulo() {
  //   return AgregarArticulo(Dependencias.ventas.repositorioVentas());
  // }

  // static CrearVenta crearVenta() {
  //   return CrearVenta();
  // }

  // static CobrarVenta cobrarVenta() {
  //   return CobrarVenta(Dependencias.ventas.repositorioVentas());
  // }

  // static ObtenerVenta obtenerVenta() {
  //   return ObtenerVenta(Dependencias.ventas.repositorioVentas());
  // }
}
