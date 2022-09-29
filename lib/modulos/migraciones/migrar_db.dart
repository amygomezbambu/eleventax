import 'package:eleventa/modulos/migraciones/repositorio_migraciones.dart';
import 'package:eleventa/modulos/migraciones/registro_de_migraciones.dart'
    as registro_de_migraciones;

class MigrarDB {
  MigrarDB();

  Future<void> exec() async {
    Object? error;
    var version = 0;

    await RepositorioDeMigraciones.crearTablaMigracionesSiNoExiste();

    version = await RepositorioDeMigraciones.obtenerUltimaVersion();

    var migraciones = registro_de_migraciones.obtenerMigraciones();

    for (var migracion in migraciones) {
      try {
        if (migracion.version > version) {
          await migracion.exec();
          version = migracion.version;
        }
      } catch (e) {
        error = e;
        break;
      }
    }

    await RepositorioDeMigraciones.guardarUltimaVersion(version);

    if (error != null) {
      //si una migración falló debemos cerrar el programa ya que la db
      //quedo en un estado invalido, pero debemos hacer algo mas? , debemos
      //dar un tiempo de espera antes de cerrar? o debemos dejarle la
      //responsabilidad a la UI para que avise primero al usuario?

      //por lo pronto solo hacemos rethrow
      throw error;
    }
  }
}
