import 'package:eleventa/modules/common/app/usecase/usecase.dart';

class InitializeRequest {
  var token = '';
}

class InitializeUseCase extends Usecase<bool> {
  final request = InitializeRequest();

  InitializeUseCase() {
    operation = _operation;
  }

  Future<bool> _operation() async {
    //Obtener el deviceId actual de la config local

    //Si no existe un device Id crearlo

    //almacenarlo en la config local

    return false;
  }
}
