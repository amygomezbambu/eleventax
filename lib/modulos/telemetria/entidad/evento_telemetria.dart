// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';

class EventoTelemetria {
  final UID _uid;
  final TipoEventoTelemetria? _tipo;
  final bool _esPerfil;
  final String _ip;
  final Map<String, dynamic> _propiedades;

  UID get uid => _uid;
  TipoEventoTelemetria? get tipo => _tipo;
  bool get esPerfil => _esPerfil;
  String get ip => _ip;
  Map<String, dynamic> get propiedades => _propiedades;

  EventoTelemetria({
    required UID uid,
    TipoEventoTelemetria? tipo,
    bool esPerfil = false,
    required String ip,
    required Map<String, dynamic> propiedades,
  })  : _uid = uid,
        _tipo = tipo,
        _esPerfil = esPerfil,
        _ip = ip,
        _propiedades = propiedades;
}
