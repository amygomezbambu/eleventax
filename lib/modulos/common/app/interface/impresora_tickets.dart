import 'package:eleventa/modulos/common/app/interface/impresion.dart';

enum AnchoTicket { mm58, mm80 }

abstract class IImpresoraDeTickets extends IImpresora {
  Future<bool> abrirCajon();
  configurarImpresora(AnchoTicket anchoTicket);
}
