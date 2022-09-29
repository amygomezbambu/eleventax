class InfoDispositivo {
  var altoPantalla = 0.0;
  var anchoPantalla = 0.0;
  var pais = '';
  var lenguajeConfigurado = '';
  var modelo = '';
  var fabricante = '';
  var nombre = '';
  var sistemaOperativo = '';
  var zonaHoraria = '';
}

abstract class IAdaptadorDeDispositivo {
  Future<InfoDispositivo> obtenerDatos();
}
