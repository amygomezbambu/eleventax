import 'package:eleventa/modulos/ventas/read_models/venta.dart';

abstract class IImpresion {
  IImpresora? impresoraTickets;
  IImpresora? impresoraDocumentos;

  Future<List<String>> obtenerImpresorasDisponibles();
  Future<void> imprimirTicket(VentaDto venta);
}

abstract class IImpresora {
  void imprimir(List<String> lineasAImprimir);
  void imprimirPaginaDePrueba();
}
