import 'package:hlc/hlc.dart';

import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/sync/config.dart';

class CampoEventoSync {
  static const crdtBoolean = 'B';
  static const crdtString = 'S';
  static const crdtNumber = 'N';
  static const crdtNull = 'Null';

  final String nombre;
  late final String tipo;
  late final String valor;

  CampoEventoSync.crear({
    required this.nombre,
    Object? valor,
  }) {
    _setValue(valor);
  }

  CampoEventoSync.cargar({
    required this.nombre,
    required this.valor,
    required this.tipo,
  });

  void _setValue(Object? value) {
    if (value == null) {
      tipo = crdtNull;
      valor = crdtNull;
    } else if (value.runtimeType.toString() == 'bool') {
      tipo = crdtBoolean;
      valor = value.toString();
    } else if (double.tryParse(value.toString()) != null) {
      tipo = crdtNumber;
      valor = value.toString();
    } else {
      tipo = crdtString;
      valor = value.toString();
    }
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'valor': valor,
        'tipo': tipo,
      };
}

class EventoSync {
  //private fields
  final String _usuarioUID;
  final String _dispositivoID;
  final TipoEventoSync _tipo;
  final String _rowId;
  final String _dataset;
  final int _version;
  late final List<CampoEventoSync> _campos;

  //public fields
  late HLC hlc;

  //getters
  String get usuarioUID => _usuarioUID;
  String get dispositivoID => _dispositivoID;
  TipoEventoSync get tipo => _tipo;
  String get rowId => _rowId;
  String get dataset => _dataset;
  int get version => _version;
  List<CampoEventoSync> get campos => List.unmodifiable(_campos);
  int get timestamp => hlc.timestamp;

  EventoSync({
    TipoEventoSync tipo = TipoEventoSync.crear,
    required String rowId,
    required String dataset,
    required int version,
    required List<CampoEventoSync> campos,
    required String usuarioUID,
    required String dispositivoID,
  })  : _usuarioUID = usuarioUID,
        _tipo = tipo,
        _rowId = rowId,
        _dispositivoID = dispositivoID,
        _dataset = dataset,
        _version = version,
        _campos = campos {
    hlc = HLC.now(syncConfig!.deviceId);

    // _campos = campos.entries
    //     .map(
    //       (e) => CampoEventoSync(
    //         nombre: e.key,
    //         valor: e.value,
    //       ),
    //     )
    //     .toList();
  }

  Map<String, dynamic> toJson() => {
        'dataset': _dataset,
        'rowId': _rowId,
        'usuario_uid': _usuarioUID,
        'dispositivo_id': _dispositivoID,
        'hlc': hlc.pack(),
        'groupId': syncConfig!.groupId,
        'tipo_evento': _tipo.index,
        'version': _version,
        'campos': campos,
      };
}
