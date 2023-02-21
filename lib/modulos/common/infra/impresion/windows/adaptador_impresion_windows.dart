import 'package:eleventa/modulos/common/app/interface/impresion.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/obtener_listado_impresoras.dart';

class AdaptadorImpresionWindows implements IImpresion {
  @override
  IImpresora? impresoraTickets;
  @override
  IImpresora? impresoraDocumentos;

  @override
  Future<List<String>> obtenerImpresorasDisponibles() async {
    return await ObtenerListadoDeImpresoras.obtener();
  }
}
