import 'package:eleventa/modulos/common/utils/uid.dart';

class UnidadDeMedida {
  final UID _uid;
  final String _nombre;
  final String _abreviacion;

  UID get uid => _uid;
  String get nombre => _nombre;
  String get abreviacion => _abreviacion;

  UnidadDeMedida({
    required UID uid,
    required String nombre,
    required String abreviacion,
  })  : _uid = uid,
        _nombre = nombre,
        _abreviacion = abreviacion;
}
