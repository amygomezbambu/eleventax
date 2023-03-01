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

    lineasAImprimir.add('================================');
    for (var articulo in venta.articulos) {
      lineasAImprimir.add(
          '${articulo.cantidad} | ${articulo.descripcion} | ${articulo.subtotal}');
    }

    lineasAImprimir.add('================================');
    lineasAImprimir.add('Subtotal: ${venta.subtotal.toString()}');

    //TODO: Agregar porcentaje a los impuestos cobrados
    for (var impuestoCobrado in venta.totalesDeImpuestos) {
      lineasAImprimir.add('${impuestoCobrado.impuesto} '
          '${impuestoCobrado.porcentaje.toString()}: '
          '${impuestoCobrado.monto.toString()}');
    }

    lineasAImprimir.add('Total: ${venta.total}');
    lineasAImprimir.add('Artículo: ${venta.articulos.length}');
    lineasAImprimir.add('');
    lineasAImprimir.add('Formas de Pago');
    lineasAImprimir.add('');
    for (var pago in venta.pagos) {
      lineasAImprimir.add('${pago.forma}: ${pago.monto.toString()}');

      if (pago.pagoCon != null) {
        lineasAImprimir.add('Pago con: ${pago.pagoCon}');
      }
    }
    lineasAImprimir.add('');
    lineasAImprimir.add('Gracias por su compra, vuelva pronto!');

    impresoraTickets!.imprimir(lineasAImprimir);
  }

  Future<void> testTicket() async {
    if (impresoraTickets == null) {
      throw ValidationEx(
          mensaje: 'No se ha configurado la impresora de tickets',
          tipo: TipoValidationEx.errorDeValidacion);
    }

    List<String> lineasAImprimir = [];
    var comando = '27 33 54';
    lineasAImprimir.add(comando);
    lineasAImprimir.add('Ticket de prueba');
    //TODO: agregar datos de negocio

    lineasAImprimir.add('Gracias por su compra, vuelva pronto!');

    const openCashDrawer = '\x1b\x70\x00';
    lineasAImprimir.add(openCashDrawer);

    const ESC = "\u001B"; // ESC command
    const GS = "\u001D"; // Group separator

    const InitializePrinter = ESC + "@"; // Reset printer
    const BoldOn = ESC + "E" + "\u0001"; // Bold font ON
    const BoldOff = ESC + "E" + "\0"; // Bold font OFF
    const DoubleOn =
        GS + "!" + "\u0011"; // 2x sized text (double-high + double-wide)
    const DoubleOff = GS + "!" + "\0"; // Normal text

    const UnderlineOn = ESC + "-" + "\u0001"; // Underline font 1-dot ON
    const UnderlineOff = ESC + "-" + "\0"; // Underline font 1-dot OFF

    const ReverseOn = GS + "B" + "\u0001"; // Reverse color ON
    const ReverseOff = GS + "B" + "\0"; // Reverse color OFF

    const UpsideDownOn = ESC + "{" + "\u0001"; // Upside down ON
    const UpsideDownOff = ESC + "{" + "\0"; // Upside down OFF

    const SmallOn = ESC + "M" + "\u0001"; // Small font ON
    const SmallOff = ESC + "M" + "\0"; // Small font OFF

    const Cut = GS + "V" + "\u0001"; // Full cut paper

    const FeedAndFullCut = GS + "V" + "\u0001"; // Full cut paper

    const FeedAndPartialCut = GS + "V" + "\u0000"; // Partial cut paper

    const AlignLeft = ESC + "a" + "\u0000"; // Left justification

    const AlignCenter = ESC + "a" + "\u0001"; // Centering

    const AlignRight = ESC + "a" + "\u0002"; // Right justification

    const FontA = ESC + "M" + "\u0000"; // Font type A

    const FontB = ESC + "M" + "\u0001"; // Font type B

    const FontC = ESC + "M" + "\u0002"; // Font type C

    const CodePage = ESC + "t" + "\u0011"; // Code page spanish

    const Tab = "\u0009"; // Tab

    const PrintAndFeed = ESC + "d" + "\u000A"; // Print and feed paper

    // Control characters
    // as labelled in https://www.novopos.ch/client/EPSON/TM-T20/TM-T20_eng_qr.pdf
    const NUL = "\x00";
    const EOT = "\x04";
    const ENQ = "\x05";
    const DLE = "\x10";
    const DC4 = "\x14";
    const CAN = "\x18";
    const FS = "\x1c";

// Feed control sequences
    const CTL_LF = "\n"; // Print and line feed
    const CTL_FF = "\f"; // Form feed
    const CTL_CR = "\r"; // Carriage return

    lineasAImprimir.add(InitializePrinter);
    lineasAImprimir.add("${BoldOn}Here is some bold text.$BoldOff");
    lineasAImprimir.add("Here is some normal text.");
    lineasAImprimir.add("${BoldOn}Here is some bold text.$BoldOff");
    lineasAImprimir.add("${DoubleOn}Here is some large text.$DoubleOff");
    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);
    // lineasAImprimir.add(
    //     ''' Lorem Ipsum is simply dummy text of the printing and typesetting industry.$CTL_CR$CTL_LF
    //                      Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled
    //                       it to make a type specimen book.$CTL_CR$CTL_LF It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.''');
    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);

    const BeginQRCode = "\x0a"; // Beginning line feed
    const StartQRCode = "\x1c\x7d\x25"; // Start QR Code® command
    const LengthQRCode =
        "\x15"; // Length of string to follow (21 bytes in this example)
    const EndQRCode = "\x0a"; // Ending line feed
    const Eleventa = "https://eleventa.com/";

    lineasAImprimir.add(BeginQRCode);
    lineasAImprimir.add(StartQRCode);
    lineasAImprimir.add(LengthQRCode);
    lineasAImprimir.add(Eleventa);
    lineasAImprimir.add(EndQRCode);

    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);

    const Barcode = "\x1d\x6b\x49"; // Barcode command
    const BarcodeEleventa =
        "\x68\x74\x74\x70\x73\x3A\x2F\x2F\x65\x6C\x65\x76\x65\x6E\x74\x61\x2E\x63\x6F\x6D\x2F"; // Barcode command

    lineasAImprimir.add(Barcode + BarcodeEleventa);
    lineasAImprimir.add(CTL_LF);
    lineasAImprimir.add(CTL_LF);

    /*# Encode the text "pi = 3.14159265" as a Code 128 barcode,
    # using form 2 of the command, and modes B and C
    # Command header (includes code system and string length)*/
    lineasAImprimir.add("\x1d\x6b\x49\x0f\x7b\x42\x70\x69\x20\x3a\x20\x33\x2e\x7b\x43\x0e\x0f\x5c\x41");

    //
    //

    // Send to print all the lines at once
    impresoraTickets!.imprimir(lineasAImprimir);
  }
}
