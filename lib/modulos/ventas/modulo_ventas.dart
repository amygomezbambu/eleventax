import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/ventas/config_ventas.dart';
// import 'package:eleventa/modulos/ventas/app/usecase/agregar_articulo.dart';
// import 'package:eleventa/modulos/ventas/app/usecase/cobrar_venta.dart';
// import 'package:eleventa/modulos/ventas/app/usecase/crear_venta.dart';

import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/usecases/cobrar_venta.dart';
import 'package:eleventa/modulos/ventas/usecases/guardar_venta_en_progreso.dart';

class ModuloVentas {
  //TODO: refactor para que quede como en productos
  static final configLocal = ConfigLocalDeVentas();

  static GuardarVentaEnProgreso guardarVenta() {
    return GuardarVentaEnProgreso(Dependencias.ventas.repositorioVentas(),
        Dependencias.ventas.repositorioConsultasVentas());
  }

  static IRepositorioConsultaVentas repositorioConsultaVentas() {
    return Dependencias.ventas.repositorioConsultasVentas();
  }

  static CobrarVenta cobrarVenta() {
    return CobrarVenta(Dependencias.ventas.repositorioVentas());
  }
}
