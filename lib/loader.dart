import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/database.dart';
import 'package:eleventa/modules/migrations/migrate_db.dart';
import 'package:flutter/material.dart';

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class Loader {
  IDatabaseAdapter dbAdapter = Dependencies.infra.database();

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    //Conectar adaptador de base de datos.
    await dbAdapter.connect();

    //2.- Cargar la configuracion

    //3.- Ejecutar Migraciones
    var migrateDB = MigrateDB();
    await migrateDB.exec();
  }
}
