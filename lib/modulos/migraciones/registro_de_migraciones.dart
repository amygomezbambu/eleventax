import 'package:eleventa/modulos/migraciones/migracion.dart';
import 'package:eleventa/modulos/migraciones/scripts/0001_crear_tablas_iniciales.dart';
import 'package:eleventa/modulos/migraciones/scripts/0002_agregar_datos_iniciales.dart';
import 'package:eleventa/modulos/migraciones/scripts/0003_crear_tablas_sync.dart';
import 'package:eleventa/modulos/migraciones/scripts/0004_crear_tablas_config.dart';

List<Migracion> obtenerMigraciones() {
  var migraciones = <Migracion>[];

  migraciones.add(Migracion1());
  migraciones.add(Migracion2());
  migraciones.add(Migracion3());
  migraciones.add(Migracion4());

  //TODO: Ordenar las migraciones antes de retornarlas
  return migraciones;
}
