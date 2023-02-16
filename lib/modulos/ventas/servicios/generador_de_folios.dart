import 'package:eleventa/modulos/ventas/modulo_ventas.dart';

/// Genera el siguiente folio unico de ventas para el prefijo configurado
/// si es la primera venta para dicho prefijo, regresa el folio inicial
Future<String> generarFolio() async {
  final consultas = ModuloVentas.repositorioConsultaVentas();
  var folio = await consultas.obtenerFolioDeVentaMasReciente();

  if (folio == null) {
    folio = '${ModuloVentas.configLocal.prefijoFolioVentas}-'
        '${ModuloVentas.configLocal.folioInicial}';
  } else {
    int incremental = int.parse(folio.split('-')[1]);
    incremental++;

    folio = '${ModuloVentas.configLocal.prefijoFolioVentas}-$incremental';
  }

  return folio;
}
