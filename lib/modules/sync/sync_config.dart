import 'package:eleventa/modules/sync/error.dart';

enum SyncMethod { pull, realtime }

class SyncConfig {
  var _addChangesEndpoint = '';
  var _getChangesEndpoint = '';

  //solo para pruebas, nunca se deben borrar los cambios en prduccion
  var _deleteChangesEndpoint = '';
  var _dbVersionTable = '';
  var _dbVersionField = '';
  var _groupId = '';
  var _deviceId = '';
  var _pullInterval = 30000;
  var _syncMethod = SyncMethod.pull;

  _validatePullInterval(int value) {
    if (value < 1000) {
      throw SyncError(
          'El intervalo es demasiado pequeño, el valor minimo es de 3 segundos',
          '');
    }

    _pullInterval = value;
  }

  _validateDeviceId(String value) {
    if (value == '') {
      throw SyncError('El nombre del dispositivo no puede estar vacio', '');
    }

    _deviceId = value;
  }

  _validateDbVersionTable(String value) {
    if (value == '') {
      throw SyncError(
          'El nombre de la tabla que contiene la versión de la db no puede ser vacio',
          '');
    }

    _dbVersionTable = value;
  }

  _validateDbVersionField(String value) {
    if (value == '') {
      throw SyncError(
          'El nombre del campo que contiene la versión de la db no puede ser vacio',
          '');
    }

    _dbVersionField = value;
  }

  _validateGruopId(String value) {
    if (value == '') {
      throw SyncError('El identificador de grupo no puede ser vacio', '');
    }

    _groupId = value;
  }

  String get dbVersionTable => _dbVersionTable;
  String get dbVersionField => _dbVersionField;
  String get groupId => _groupId;
  String get deviceId => _deviceId;
  int get pullInterval => _pullInterval;
  SyncMethod get syncMethod => _syncMethod;
  String get addChangesEndpoint => _addChangesEndpoint;
  String get getChangesEndpoint => _getChangesEndpoint;
  String get deleteChangesEndpoint => _deleteChangesEndpoint;

  // #region singleton
  static final SyncConfig _instance = SyncConfig._internal();

  /// Construye una clase para manejar la Sincronización
  ///
  /// Se deben propocionar los siguientes datos:
  ///
  /// [dbPath] es la ruta completa incluyendo el nombre de archivo de la DB
  ///
  /// [dbVersionTable] es la tabla que contiene la información de la versión de la DB
  ///
  /// [dbVersionField] es el campo que contiene la versión de la DB
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
  factory SyncConfig.create(
      {required String dbVersionTable,
      required String dbVersionField,
      required String groupId,
      required String deviceId,
      required String addChangesEndpoint,
      required String getChangesEndpoint,
      required String deleteChangesEndpoint,
      int pullInterval = 30000,
      SyncMethod syncMethod = SyncMethod.pull}) {
    var instance = _instance;

    instance._validateDbVersionField(dbVersionField);
    instance._validateDbVersionTable(dbVersionTable);
    instance._validateDeviceId(deviceId);
    instance._validateGruopId(groupId);
    instance._validatePullInterval(pullInterval);

    instance._addChangesEndpoint = addChangesEndpoint;
    instance._getChangesEndpoint = getChangesEndpoint;
    instance._deleteChangesEndpoint = deleteChangesEndpoint;

    instance._syncMethod = syncMethod;

    return instance;
  }

  factory SyncConfig.get() => _instance;

  SyncConfig._internal();
}
