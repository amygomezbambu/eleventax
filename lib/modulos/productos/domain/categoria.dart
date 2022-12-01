import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';

class Categoria extends Entidad {
  final NombreCategoria _nombre;

  String get nombre => _nombre.value;

  Categoria.crear({required NombreCategoria nombre})
      : _nombre = nombre,
        super.crear();

  Categoria.cargar({
    required UID uid,
    required NombreCategoria nombre,
    required bool eliminado,
  })  : _nombre = nombre,
        super.cargar(uid, eliminado: eliminado);

  Map<String, dynamic> toMap() {
    final result = {
      'uid': uid_.toString(),
      'nombre': _nombre.value,
    };

    return result;
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria.crear(nombre: NombreCategoria(map['nombre']));
  }

  Categoria copyWith({
    UID? uid,
    NombreCategoria? nombre,
    bool? eliminado,
  }) {
    var copia = Categoria.crear(
      nombre: nombre ?? _nombre,
    );

    copia.uid_ = uid ?? uid_;
    copia.eliminado_ = eliminado ?? eliminado_;
    return copia;
  }

  @override
  String toString() => 'Categoria(_nombre: $_nombre)';
}
