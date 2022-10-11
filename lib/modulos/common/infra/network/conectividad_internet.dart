import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Verifica si tenemos conexion a través de un DNS lookup
/// y actualiza su estado cada que la conexión cambia (celular, wifi, bluetooth, ethernet, etc)
class ConectividadDeInternet {
  bool estaConectado = false;
  final _networkConnectivity = Connectivity();

  ConectividadDeInternet._();

  static final _instance = ConectividadDeInternet._();

  static Future<ConectividadDeInternet> getInstance() async {
    ConectividadDeInternet instancia = _instance;

    await instancia.inicializar();

    return instancia;
  }

  Future<void> inicializar() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    await _verificarEstado(result);

    _networkConnectivity.onConnectivityChanged.listen((result) {
      _verificarEstado(result);
    });
  }

  Future<void> _verificarEstado(ConnectivityResult result) async {
    estaConectado = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      estaConectado = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      estaConectado = false;
    }
  }
}
