//NOTA , puede existir 2 unidades de medida Pieza , mismo nombre pero distinto ID?
//O siempre que nos referimos a Pieza estamos hablando de la misma unidad de medida
//Creo que es lo segundo, esto es lo que define un value object, no tiene identidad
//aunque en este caso si tiene un UID ese UID siempre va a ser el mismo para todas las
//piezas
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
