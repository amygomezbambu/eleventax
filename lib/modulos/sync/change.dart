import 'package:eleventa/modulos/sync/error.dart';
import 'package:eleventa/modulos/sync/sync_config.dart';

/// Esta clase describe un cambio que se desea sincronizar
class Change {
  final crdtBoolean = 'B';
  final crdtString = 'S';
  final crdtNumber = 'N';

  final _config = SyncConfig.get();

  late String _dataset;
  late String _rowId;
  late String _column;
  late Object? _value;
  late String _hlc;
  late int _timestamp;
  late String _valueType;
  late int _version;

  String get dataset => _dataset;
  String get rowId => _rowId;
  String get column => _column;
  //NOTA: que pasa aqui? estamos pasando un objeto, se pasa la referencia o se hace una copia?
  Object? get value => _value;
  String get valueType => _valueType;
  String get hlc => _hlc;
  int get timestamp => _timestamp;
  int get version => _version;

  set hlc(String value) {
    if (value.isEmpty) {
      throw SyncEx('El HLC no puede estar vacio', '');
    }

    _timestamp = int.parse(value.split(':')[0]);

    _hlc = value;
  }

  Change.create(
      {required String column,
      required Object? value,
      required String dataset,
      required String rowId,
      required int version,
      String? hlc}) {
    _setRowId(rowId);
    _setColumn(column);
    _setValue(value);
    _setDataset(dataset);
    _setVersion(version);

    if (hlc != null) {
      this.hlc = hlc;
    }
  }

  Change.load(
      {required String column,
      required Object? value,
      required String dataset,
      required String rowId,
      required String hlc,
      required int version}) {
    _setRowId(rowId);
    _setColumn(column);
    _setValue(value);
    _setDataset(dataset);
    _setVersion(version);

    //se usa de esta manera porque es un setter publico
    this.hlc = hlc;
  }

  void _setDataset(String value) {
    if (value.isEmpty) {
      throw SyncEx('El dataset no puede estar vacio', '');
    }

    _dataset = value;
  }

  void _setColumn(String value) {
    if (value.isEmpty) {
      throw SyncEx('El nombre de la columna no puede estar vacio', '');
    }

    _column = value;
  }

  void _setValue(Object? value) {
    _value = value;

    _determineValueType(value);
  }

  void _setRowId(String value) {
    if (value.isEmpty) {
      throw SyncEx('El identificador de renglon no puede estar vacio', '');
    }

    _rowId = value;
  }

  void _setVersion(int value) {
    if (value <= 0) {
      throw SyncEx('Se debe proporcionar una version de cambio valida', '');
    }

    _version = value;
  }

  void _determineValueType(Object? value) {
    if (value == null) {
      _valueType = value.toString();
    } else if (value.runtimeType.toString() == 'bool') {
      _valueType = crdtBoolean;
    } else if (double.tryParse(value.toString()) != null) {
      _valueType = crdtNumber;
    } else {
      _valueType = crdtString;
    }
  }

  Map<String, String> toJson() => {
        'dataset': _dataset,
        'rowId': _rowId,
        'column': _column,
        'value': _value.toString(),
        'hlc': _hlc,
        'groupId': _config.groupId,
        'type': _valueType,
        'timestamp': _timestamp.toString(),
        'version': _version.toString()
      };
}
