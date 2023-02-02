// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

class Impuesto extends Entidad {
  final String _nombre;
  final double _porcentaje;
  final int _ordenDeAplicacion;
  final bool _activo;

  String get nombre => _nombre;
  int get ordenDeAplicacion => _ordenDeAplicacion;
  bool get activo => _activo;

  /// Porcentaje en decimal, ejem: 16.00, 1.3333, etc.
  double get porcentaje => _porcentaje;

  Impuesto.cargar({
    required UID uid,
    required String nombre,
    required double porcentaje,
    required int ordenDeAplicacion,
    required bool activo,
  })  : _nombre = nombre,
        _porcentaje = porcentaje,
        _ordenDeAplicacion = ordenDeAplicacion,
        _activo = activo,
        super.cargar(uid);

  /// Crea un Impuesto
  ///
  /// Ejemplo:
  /// ```dart
  /// Impuesto.crear(nombre: 'IVA', porcentaje: 16.00);
  /// ```
  Impuesto.crear({
    required String nombre,
    required double porcentaje,
    required int ordenDeAplicacion,
  })  : _nombre = nombre,
        _porcentaje = porcentaje,
        _ordenDeAplicacion = ordenDeAplicacion,
        _activo = true,
        super.crear();

  @override
  String toString() => '''
      Impuesto(nombre: $_nombre, porcentaje: $_porcentaje, 
      ordenDeAplicacion: $_ordenDeAplicacion, activo: $_activo)
      ''';
}
