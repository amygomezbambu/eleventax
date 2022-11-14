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

    //TODO: no debe tener el default
    _dbPassword =
        const String.fromEnvironment('DB_PASSWORD', defaultValue: '12345');
  }
}

//TODO: obtener los datos reales
class Propietario {
  var nombres = 'Luis Alberto';
  var apellido = 'Carrasco';
  var correo = 'luis@bambucode.com';
  var telefono = '6144444444';
}

class Negocio {
  var nombre = 'Super Chiwas';
  var propietario = Propietario();
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
  var negocio = Negocio();

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

    deviceId = uid != null ? UID.fromString(uid) : _generarDatosIniciales();

    await guardar();
  }

  UID _generarDatosIniciales() {
    return UID();
  }
}
