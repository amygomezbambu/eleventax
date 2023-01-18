import 'package:eleventa/modulos/migraciones/migracion.dart';
import 'package:eleventa/modulos/migraciones/scripts/0001_crear_tablas_iniciales.dart';
import 'package:eleventa/modulos/migraciones/scripts/0002_agregar_datos_iniciales.dart';
import 'package:eleventa/modulos/migraciones/scripts/0003_crear_tablas_sync.dart';
import 'package:eleventa/modulos/migraciones/scripts/0004_crear_tablas_config.dart';
import 'package:eleventa/modulos/migraciones/scripts/0005_crear_tablas_notificaciones.dart';
import 'package:eleventa/modulos/migraciones/scripts/0006_crear_tabla_queue_metricas.dart';
import 'package:eleventa/modulos/migraciones/scripts/0007_crear_tablas_ventas.dart';

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
  migraciones.add(Migracion6());
  migraciones.add(Migracion7());

  return migraciones;
}
