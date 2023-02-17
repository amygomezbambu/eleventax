import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class PagoEnEfectivoWidget extends StatelessWidget {
  final _esDesktop = LayoutValue(xs: false, md: true);

  PagoEnEfectivoWidget({
    super.key,
    required this.formaDePago,
    required this.textEditController,
  });

  final FormaDePago formaDePago;
  final TextEditingController textEditController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExTextField(
          hintText: formaDePago.tipo == TipoFormaDePago.efectivo
              ? 'Pagó con'
              : 'Referencia',
          controller: textEditController,
          width: 300,
        ),
        formaDePago.tipo == TipoFormaDePago.efectivo
            ? const Text('Su Cambio: 0.00')
            : const SizedBox(),
        // El botón de registrar solo se muestra en mobile
        !_esDesktop.resolve(context)
            ? ExBoton.primario(
                label: 'Registrar',
                icon: Icons.save,
                onTap: () {
                  try {
                    var montoRecibido = Moneda(textEditController.text);
                    Navigator.pop(context, montoRecibido);
                  } catch (e) {
                    // TODO: Manejar excepciones al capturar el monto recibido
                    debugPrint(e.toString());
                  }
                })
            : const SizedBox(),
      ],
    );
  }
}
