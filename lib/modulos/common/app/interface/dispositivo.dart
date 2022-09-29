class InfoDispositivo {
  var altoPantalla = 0.0;
  var anchoPantalla = 0.0;
  var pais = '';
  var lenguajeConfigurado = '';

  /// Modelo del dispositivo (iPad, Pixel, etc)
  var modelo = '';
  var fabricante = '';

  /// Nombre del dispositivo (ejem: iPad Luis, PC-SERVIDOR, etc.)
  var nombre = '';
  var sistemaOperativo = '';

  /// Diferencia de la zona horaria con UTC
  int zonaHoraria = 0;
}

abstract class IAdaptadorDeDispositivo {
  Future<InfoDispositivo> obtenerDatos();
}
