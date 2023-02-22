import 'package:eleventa/modulos/common/app/interface/impresion.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/obtener_listado_impresoras.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';

class AdaptadorImpresionWindows implements IImpresion {
  @override
  IImpresora? impresoraTickets;
  @override
  IImpresora? impresoraDocumentos;

  @override
  Future<List<String>> obtenerImpresorasDisponibles() async {
    return await ObtenerListadoDeImpresoras.obtener();
  }

  @override
  Future<void> imprimirTicket(VentaDto venta) async {
    if (impresoraTickets == null) {
      throw ValidationEx(
          mensaje: 'No se ha configurado la impresora de tickets',
          tipo: TipoValidationEx.errorDeValidacion);
    }

    List<String> lineasAImprimir = [];

// Forma de pago usada
// Lineas finales de ticket (texto libre)
// 5.5 - En caso de que la cantidad, nombre del producto e importe superen el ancho del ticket se optará por pasar el nombre del
//producto a una segunda o tercera línea según corresponda para respetar que la linea completa del articulo aparezca justificada.

    lineasAImprimir.add('Ticket de prueba');
    //TODO: agregar datos de negocio
    lineasAImprimir.add('ABARROTES EL CHAPARRAL');
    lineasAImprimir.add('Direccion: Av. 5 de Mayo # 123');
    lineasAImprimir.add('Folio: ${venta.folio}');
    lineasAImprimir.add('Fecha/Hora: ${venta.cobradaEn.toString()}');
    //TODO: agregar datos del cajero que cobro la venta
    lineasAImprimir.add('Cajero: Raul');

    lineasAImprimir.add('========================================');
    for (var articulo in venta.articulos) {
      lineasAImprimir.add(
          '${articulo.cantidad} | ${articulo.descripcion} | ${articulo.subtotal}');
    }
    
    lineasAImprimir.add('========================================');
    lineasAImprimir.add('Subtotal: ${venta.subtotal.toString()}');
    
    //TODO: Agregar porcentaje a los impuestos cobrados
    for (var impuestoCobrado in venta.totalesDeImpuestos) {
        lineasAImprimir.add(
          '${impuestoCobrado.impuesto} '
          '${impuestoCobrado.porcentaje.toString()}: '
          '${impuestoCobrado.monto.toString()}');
    }

    lineasAImprimir.add('Total: ${venta.total}');
    lineasAImprimir.add('Artículo: ${venta.articulos.length}');
    lineasAImprimir.add('');
    lineasAImprimir.add('Formas de Pago');
    lineasAImprimir.add('');
    for(var pago in venta.pagos){
      lineasAImprimir.add('${pago.forma}: ${pago.monto.toString()}');

      if(pago.pagoCon != null){
        lineasAImprimir.add('Pago con: ${pago.pagoCon}');
      }
    }

    lineasAImprimir.add('');
    lineasAImprimir.add('Gracias por su compra, vuelva pronto!');

    impresoraTickets!.imprimir(lineasAImprimir);
  }
}
