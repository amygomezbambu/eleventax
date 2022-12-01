import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/loader/iniciar_dependencias.dart';
import 'package:eleventa/modulos/loader/iniciar_sincronizacion.dart';
import 'package:eleventa/modulos/migraciones/migrar_db.dart';
import 'package:eleventa/modulos/telemetria/modulo_telemetria.dart';
import 'package:flutter/material.dart';

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class Loader {
  late IAdaptadorDeBaseDeDatos adaptadorDB;
  late ILogger logger;

  /* #region Singleton */
  static final Loader _instance = Loader._internal();

  factory Loader() {
    return _instance;
  }

  Loader._internal();
  /* #endregion */

  Future<void> iniciarLogging() async {
    logger = Dependencias.infra.logger();

    await logger.iniciar(
      config: LoggerConfig(
        nivelesRemotos: [NivelDeLog.error],
        nivelesDeArchivo: [NivelDeLog.error, NivelDeLog.warning],
        nivelesDeConsola: [NivelDeLog.all],
      ),
    );
  }

  Future<void> iniciarDB() async {
    adaptadorDB = Dependencias.infra.database();
    await adaptadorDB.conectar();

    var migrarDB = MigrarDB();
    await migrarDB.exec();
  }

  Future<void> enviarMetricasIniciales() async {
    var telemetria = ModuloTelemetria.enviarMetricasIniciales();

    await telemetria.exec();
  }

  //TODO: DIVIDIR EN iniciar sistemas criticos y no criticos, los no criticos
  //no deben detener la carga del programa, solo se logea
  Future<void> iniciar() async {
    WidgetsFlutterBinding.ensureInitialized();

    DependenciasLoader.init();

    await appConfig.cargar();
    await iniciarLogging();
    await iniciarDB();
    await SincronizacionLoader.iniciar();

    await enviarMetricasIniciales();
  }
}
