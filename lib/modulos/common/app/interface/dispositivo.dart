class InfoDispositivo {
  /// Alto de la pantalla en pixeles lógicos
  var altoPantalla = 0.0;

  /// Ancho de la pantalla en pixeles lógicos
  var anchoPantalla = 0.0;
  var pais = '';
  var lenguajeConfigurado = '';

  /// Modelo del dispositivo (iPad, Pixel, etc)
  var modelo = '';
  var fabricante = '';

  /// Nombre del dispositivo (ejem: iPad Luis, PC-SERVIDOR, etc.)
  var nombre = '';
  var so = '';
  var versionSO = '';

  /// Diferencia de la zona horaria con UTC
  int zonaHoraria = 0;

  /// Versiones de la Aplicacion
  var appBuild = '';
  var appVersion = '';

  /// Número de veces que el usuario ha abierto la aplicación en este dispositivo
  var numeroDeEjecuciones = 0;
}

abstract class IAdaptadorDeDispositivo {
  Future<InfoDispositivo> obtenerDatos();
}
