import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/nombre_value_object.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

enum TipoFormaDePago {
  generico('ge'),
  // Tipos de "sistema" con lógica especial:
  efectivo('ef');

  static final Map<String, TipoFormaDePago> _porAbreviacion = {};

  /// Busca el TipoFormaDePago por la abreviacion, ejem: ef, ge, etc.
  /// si no existe, regresa generico por default
  static TipoFormaDePago porAbreviacion(String abreviacion) {
    if (_porAbreviacion.isEmpty) {
      for (TipoFormaDePago forma in TipoFormaDePago.values) {
        _porAbreviacion[forma.abreviacion] = forma;
      }
    }

    return _porAbreviacion[abreviacion] ?? TipoFormaDePago.generico;
  }

  const TipoFormaDePago(this.abreviacion);
  final String abreviacion;
}

class FormaDePago extends Entidad {
  final NombreValueObject _nombre;
  final int _orden;
  final bool _borrado;
  final bool _activo;
  final TipoFormaDePago _tipo;

  String get nombre => _nombre.value;
  int get orden => _orden;
  bool get borrado => _borrado;
  bool get activo => _activo;
  TipoFormaDePago get tipo => _tipo;

  FormaDePago.cargar({
    required UID uid,
    required NombreValueObject nombre,
    required int orden,
    required bool borrado,
    required bool activo,
    required TipoFormaDePago tipo,
  })  : _nombre = nombre,
        _orden = orden,
        _borrado = borrado,
        _activo = activo,
        _tipo = tipo,
        super.cargar(uid);

  FormaDePago.crear({
    required NombreValueObject nombre,
    required int orden,
  })  : _nombre = nombre,
        _orden = orden,
        _borrado = false,
        _activo = true,
        // Todas las formas de pago que el usuario cree serán genericas siempre
        _tipo = TipoFormaDePago.generico,
        super.crear();

  @override
  String toString() {
    return 'Forma De Pago: nombre: $_nombre, orden: $_orden, borrado: $_borrado, activo: $_activo';
  }
}
