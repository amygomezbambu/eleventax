// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

class UnidadDeMedida extends Entidad {
  final String _nombre;
  final String _abreviacion;

  String get nombre => _nombre;
  String get abreviacion => _abreviacion;

  UnidadDeMedida.crear({
    required String nombre,
    required String abreviacion,
  })  : _nombre = nombre,
        _abreviacion = abreviacion,
        super.crear();

  UnidadDeMedida.cargar({
    required UID uid,
    required String nombre,
    required String abreviacion,
  })  : _nombre = nombre,
        _abreviacion = abreviacion,
        super.cargar(uid);

  @override
  String toString() =>
      'UnidadDeMedida(nombre: $_nombre, abreviacion: $_abreviacion)';
}
