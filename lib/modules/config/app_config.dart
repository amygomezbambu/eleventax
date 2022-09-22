import 'package:eleventa/modules/common/infra/local_config.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

enum WindowMode { normal, maximized }

class AppConfig extends LocalConfig {
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
