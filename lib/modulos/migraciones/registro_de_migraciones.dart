import 'package:eleventa/modulos/migraciones/migracion.dart';
import 'package:eleventa/modulos/migraciones/scripts/0001_crear_tablas_iniciales.dart';
import 'package:eleventa/modulos/migraciones/scripts/0002_agregar_datos_iniciales.dart';
import 'package:eleventa/modulos/migraciones/scripts/0003_crear_tablas_sync.dart';
import 'package:eleventa/modulos/migraciones/scripts/0004_crear_tablas_config.dart';
import 'package:eleventa/modulos/migraciones/scripts/0005_crear_tablas_notificaciones.dart';

/// Registro con el listado de todas las migraciones
///
/// Deben estar ordenadas ya que se ejecutan en el orden en que son agregadas
List<Migracion> obtenerMigraciones() {
  var migraciones = <Migracion>[];

  migraciones.add(Migracion1());
  migraciones.add(Migracion2());
  migraciones.add(Migracion3());
  migraciones.add(Migracion4());
  migraciones.add(Migracion5());

  return migraciones;
}
