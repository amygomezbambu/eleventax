import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

class Impuesto extends Entidad {
  final String _nombre;
  final double _porcentaje;

  String get nombre => _nombre;
  double get porcentaje => _porcentaje;

  Impuesto.cargar({
    required UID uid,
    required String nombre,
    required double porcentaje,
  })  : _nombre = nombre,
        _porcentaje = porcentaje,
        super.cargar(uid);

  Impuesto.crear({
    required String nombre,
    required double porcentaje,
  })  : _nombre = nombre,
        _porcentaje = porcentaje,
        super.crear();
}
