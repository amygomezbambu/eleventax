abstract class IImpresion {
  IImpresora? impresoraTickets;
  IImpresora? impresoraDocumentos;
  
  Future<List<String>> obtenerImpresorasDisponibles();
}

abstract class IImpresora {
  void imprimir(List<String> lineasAImprimir);
  void imprimirPaginaDePrueba();
}
