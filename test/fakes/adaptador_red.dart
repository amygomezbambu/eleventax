import 'package:eleventa/modulos/common/app/interface/red.dart';

class AdaptadorRedFake implements IRed {
  @override
  Future<bool> hayConexionAInternet() async {
    return true;
  }

  @override
  Future<String> obtenerIPPublica() async {
    return '8.8.8.8';
  }
}
