import 'package:eleventa/modulos/common/infra/config_local.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/config/env.dart';

enum WindowMode { normal, maximized }

class Secrets {
  static String _dbPassword = '';
  static String _tokenTelemetria = '';
  static String _tokenLoggingRemoto = '';

  String get dbPassword => _dbPassword;
  String get tokenTelemetria => _tokenTelemetria;
  String get tokenLoggingRemoto => _tokenLoggingRemoto;

  Secrets() {
    _tokenTelemetria = Env.mixpanelProjectID;
    _tokenLoggingRemoto = Env.sentryDSN;

    //TODO: no debe tener el default, usar 1Password como en los otros secrets ?
    _dbPassword =
        const String.fromEnvironment('DB_PASSWORD', defaultValue: '12345');
  }
}

class AppConfig extends ConfigLocal {
  final secrets = Secrets();

  WindowMode windowMode = WindowMode.normal;
  late UID deviceId;

  String ambiente =
      const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

  var negocioID = '12345';
  var sucursalID = 'ABCDF';
  var usuarioLogeado = 'Jhon Doe';
  var dbVersion = 0;
  var decimalesAMostrar = 2;

  /*Configuracion de impresion*/
  int columnasTicket = 32;
  int lineasEspaciado = 3;
  String nombreImpresora = 'GP-5890X';


  /* #region Singleton */
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();
  /* #endregion */

  Future<void> guardar() async {
    await saveValue('deviceId', deviceId.toString());
  }

  Future<void> cargar() async {
    var uid = await readValue<String>('deviceId');

    if (uid == null) {
      deviceId = UID();
      await guardar();
    } else {
      deviceId = UID.fromString(uid);
    }
  }
}
