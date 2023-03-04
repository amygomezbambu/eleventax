import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/comandosEscPos.dart';

abstract class IImpresion {
  IImpresora? impresoraTickets;
  IImpresora? impresoraDocumentos;

  Future<List<String>> obtenerImpresorasDisponibles();
  Future<void> imprimirTicket(VentaDto venta);
}

abstract class IImpresora {
  void imprimir();
  void imprimirPaginaDePrueba();

  void agregarEspaciadoFinal();
  void agregarDivisor([String divisor = '=']);
  void agregarLinea(String linea,
      [TipoAlineacion alineacion = TipoAlineacion.izquierda,
      TipoTamanioFuente tamanioFuente = TipoTamanioFuente.normal]); 
  void agregarLineaJustificada(String campo, String valor,
      [TipoTamanioFuente tamanioFuente = TipoTamanioFuente.normal]);
  void agregarLineaEnBlanco();
}

   
