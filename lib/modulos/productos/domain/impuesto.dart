import 'package:eleventa/modulos/common/utils/uid.dart';

class Impuesto {
  final UID _uid;
  final String _nombre;
  final double _porcentaje;

  UID get uid => _uid;
  String get nombre => _nombre;
  double get porcentaje => _porcentaje;

  Impuesto({
    required UID uid,
    required String nombre,
    required double porcentaje,
  })  : _uid = uid,
        _nombre = nombre,
        _porcentaje = porcentaje;
}
