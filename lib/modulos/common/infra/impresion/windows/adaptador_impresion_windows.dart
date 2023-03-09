import 'package:eleventa/modulos/common/app/interface/impresion.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/infra/impresion/windows/comandos_esc_pos.dart';
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

    // Forma de pago usada
    // Lineas finales de ticket (texto libre)
    // 5.5 - En caso de que la cantidad, nombre del producto e importe superen el ancho del ticket se optará por pasar el nombre del
    //producto a una segunda o tercera línea según corresponda para respetar que la linea completa del articulo aparezca justificada.
    //TODO: agregar datos de negocio
    impresoraTickets!.agregarLinea('ABARROTES EL CHAPARRAL',
        TipoAlineacion.centro, TipoTamanioFuente.grande);
    impresoraTickets!.agregarLinea('Direccion: Av. 5 de Mayo # 123');
    impresoraTickets!.agregarLinea('Folio: ${venta.folio}');
    impresoraTickets!.agregarLinea('Fecha/Hora: ${venta.cobradaEn.toString()}');

    //TODO: agregar datos del cajero que cobro la venta
    impresoraTickets!.agregarLinea('Cajero: Raul');
    impresoraTickets!.agregarLineaEnBlanco();

    impresoraTickets!.agregarLineaJustificada('Cant. Descripcion', 'Importe');

    impresoraTickets!.agregarDivisor('=');

    for (var articulo in venta.articulos) {
      impresoraTickets!.agregarLineaJustificada(
          '${articulo.cantidad} ${articulo.productoNombre}',
          '${articulo.subtotal}');
    }

    impresoraTickets!.agregarDivisor('=');
    impresoraTickets!.agregarLinea(
        'Subtotal: ${venta.subtotal.toString()}', TipoAlineacion.derecha);

    //TODO: Agregar porcentaje a los impuestos cobrados
    for (var impuestoCobrado in venta.totalesDeImpuestos) {
      impresoraTickets!.agregarLinea(
          '${impuestoCobrado.nombreImpuesto} '
          '${impuestoCobrado.porcentaje.toString()}: '
          '${impuestoCobrado.monto.toString()}',
          TipoAlineacion.derecha);
    }

    impresoraTickets!
        .agregarLinea('Total: ${venta.total}', TipoAlineacion.derecha);
    impresoraTickets!.agregarLinea(
        'Artículos: ${venta.articulos.length}', TipoAlineacion.derecha);
    impresoraTickets!.agregarLineaEnBlanco();
    impresoraTickets!.agregarLinea('Formas de Pago');
    for (var pago in venta.pagos) {
      impresoraTickets!.agregarLinea('${pago.forma}: ${pago.monto.toString()}');

      if (pago.pagoCon != null) {
        impresoraTickets!.agregarLinea('Pago con: ${pago.pagoCon}');
      }
    }

    impresoraTickets!.agregarLinea('');
    impresoraTickets!
        .agregarLinea("Gracias por su compra", TipoAlineacion.centro);
    impresoraTickets!.agregarLinea("vuelva pronto!", TipoAlineacion.centro);
    impresoraTickets!.agregarLinea('https://eleventa.com',
        TipoAlineacion.centro, TipoTamanioFuente.grande);
    impresoraTickets!.agregarEspaciadoFinal();

    impresoraTickets!.imprimir();
  }
}
