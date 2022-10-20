import 'package:eleventa/modulos/common/utils/uid.dart';

class Categoria {
  final UID _uid;
  final String _nombre;

  UID get uid => _uid;
  String get nombre => _nombre;

  Categoria({required UID uid, required String nombre})
      : _uid = uid,
        _nombre = nombre;
}
