import 'package:eleventa/modules/common/infra/local_config.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

enum WindowMode { normal, maximized }

class Secrets {
  static String _databasePassword = '';
  static String _telemetryToken = '';

  String get databasePassword => _databasePassword;
  String get telemetryToken => _telemetryToken;

  Secrets() {
    _telemetryToken = const String.fromEnvironment('TELEMETRY_TOKEN');
    _databasePassword =
        const String.fromEnvironment('DB_PASSWORD', defaultValue: "123");
  }
}

class AppConfig extends LocalConfig {
  final secrets = Secrets();

  WindowMode windowMode = WindowMode.normal;
  late UID deviceId;
  var loggedUser = 'Jhon Doe';

  /* #region Singleton */
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();
  /* #endregion */

  Future<void> save() async {
    await saveValue('deviceId', deviceId);
  }

  Future<void> load() async {
    var uid = await readValue<String>('deviceId');

    deviceId = uid != null ? UID(uid) : _generateInitialData();
  }

  UID _generateInitialData() {
    return UID();
  }
}
