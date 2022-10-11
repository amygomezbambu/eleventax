import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';

class AdaptadorDispositivoFake implements IAdaptadorDeDispositivo {
  @override
  Future<InfoDispositivo> obtenerDatos() async {
    var info = InfoDispositivo();

    info.altoPantalla = 1000;
    info.anchoPantalla = 600;
    info.fabricante = 'DELL';
    info.lenguajeConfigurado = 'es';
    info.modelo = 'Inspiron 2801';
    info.nombre = 'Laptop de bambu';
    info.pais = 'MX';
    info.so = 'Linux';
    info.zonaHoraria = -5;
    info.appBuild = '100';
    info.appVersion = '0.0.1';
    info.numeroDeEjecuciones = 2;
    info.versionSO = 'Ubuntu';
    info.ip = '8.8.8.8';

    return info;
  }
}
