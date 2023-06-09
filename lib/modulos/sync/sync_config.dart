import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/entity/sync_unique_rule.dart';

enum SyncMethod { pull, realtime }

class SyncConfig {
  var _addChangesEndpoint = '';
  var _getChangesEndpoint = '';
  //solo para pruebas, nunca se deben borrar los cambios en prduccion
  var _deleteChangesEndpoint = '';
  var _dbVersion = 0;
  var _groupId = '';
  var _deviceId = '';
  var _userUID = '';

  var _syncMethod = SyncMethod.pull;
  var _sendChangesInmediatly = true;

  late int _pullInterval;
  late int _queueInterval;
  late Duration _timeout;

  final List<SyncUniqueRule> _uniqueRules = [];

  void Function(Object, StackTrace)? _onError;

  int get dbVersion => _dbVersion;
  String get groupId => _groupId;
  String get deviceId => _deviceId;
  String get userUID => _userUID;
  int get pullInterval => _pullInterval;
  int get queueInterval => _queueInterval;
  Duration get timeout => _timeout;
  SyncMethod get syncMethod => _syncMethod;
  String get addChangesEndpoint => _addChangesEndpoint;
  String get getChangesEndpoint => _getChangesEndpoint;
  String get deleteChangesEndpoint => _deleteChangesEndpoint;
  bool get sendChangesInmediatly => _sendChangesInmediatly;
  List<SyncUniqueRule> get uniqueRules => _uniqueRules;
  void Function(Object, StackTrace)? get onError => _onError;

  /// Construye una clase para manejar la Sincronización
  ///
  /// Se deben propocionar los siguientes datos:
  ///
  /// [dbPath] es la ruta completa incluyendo el nombre de archivo de la DB
  ///
  /// [dbVersion] version de la base de datos
  ///
  /// [groupId] es el grupo de sincronización que comparten todos los nodos de un negocio
  ///
  /// [nodeId] es el identificador de este dispositivo
  ///
  /// [syncMethod] es el metodo de sincronización, puede ser pull o realtime,
  /// por default es pull
  ///
  /// [pullInterval] es el tiempo en milisegundos entre cada consulta al servidor
  /// por default 30000 (30 segundos)
  ///
  /// [queueInterval] es el tiempo en milisegundos entre cada procesamiento del queue,
  /// es decir cada vez que se lee el queue y se procesan sus entradas.
  ///
  /// [timeout] es el tiempo que debe esperar el servidor antes de lanzar un error por
  /// timeout
  SyncConfig({
    required int dbVersion,
    required String groupId,
    required String deviceId,
    required String userId,
    required String addChangesEndpoint,
    required String getChangesEndpoint,
    required String deleteChangesEndpoint,
    void Function(Object, StackTrace)? onError,
    int pullInterval = 30000,
    int queueInterval = 30000,
    Duration timeout = const Duration(seconds: 15),
    SyncMethod syncMethod = SyncMethod.pull,
    bool sendChangesInmediatly = true,
  }) {
    _onError = onError;

    _validateDbVersion(dbVersion);
    _validateDeviceId(deviceId);
    _validateGruopId(groupId);
    _validateUserId(userId);
    _validatePullInterval(pullInterval);
    _validateQueueInterval(queueInterval);
    _validateTimeout(timeout);

    _addChangesEndpoint = addChangesEndpoint;
    _getChangesEndpoint = getChangesEndpoint;
    _deleteChangesEndpoint = deleteChangesEndpoint;

    _syncMethod = syncMethod;
    _sendChangesInmediatly = sendChangesInmediatly;
  }

  void registerUniqueRule({
    required String dataset,
    required String uniqueColumn,
  }) {
    _uniqueRules.add(SyncUniqueRule(
      dataset: dataset,
      column: uniqueColumn,
    ));
  }

  _validatePullInterval(int value) {
    if (value < 3000) {
      throw SyncEx(
          tipo: TiposSyncEx.configuracionIncorrecta,
          message:
              'El intervalo es demasiado pequeño, el valor minimo es de 3 segundos');
    }

    _pullInterval = value;
  }

  _validateQueueInterval(int value) {
    if (value < 10000) {
      throw SyncEx(
        tipo: TiposSyncEx.configuracionIncorrecta,
        message:
            'El intervalo es demasiado pequeño, el valor minimo es de 10 segundos',
      );
    }

    _queueInterval = value;
  }

  _validateTimeout(Duration value) {
    if (value > const Duration(seconds: 30)) {
      throw SyncEx(
        tipo: TiposSyncEx.configuracionIncorrecta,
        message:
            'El timeout es demasiado grande, el valor maximo es de 30 segundos',
      );
    }

    _timeout = value;
  }

  _validateDeviceId(String value) {
    if (value == '') {
      throw SyncEx(
          tipo: TiposSyncEx.configuracionIncorrecta,
          message: 'El nombre del dispositivo no puede estar vacio');
    }

    _deviceId = value;
  }

  _validateDbVersion(int value) {
    if (value < 1) {
      throw SyncEx(
        tipo: TiposSyncEx.configuracionIncorrecta,
        message: 'La version de Db debe ser mayor a 0',
      );
    }

    _dbVersion = value;
  }

  _validateUserId(String value) {
    if (value == '') {
      throw SyncEx(
          tipo: TiposSyncEx.configuracionIncorrecta,
          message: 'El identificador de usuario no puede ser vacio');
    }

    _userUID = value;
  }

  _validateGruopId(String value) {
    if (value == '') {
      throw SyncEx(
          tipo: TiposSyncEx.configuracionIncorrecta,
          message: 'El identificador de grupo no puede ser vacio');
    }

    _groupId = value;
  }
}
