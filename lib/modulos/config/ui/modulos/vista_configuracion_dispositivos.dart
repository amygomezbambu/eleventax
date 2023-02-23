import 'package:eleventa/modulos/config/ui/opcion_configurable.dart';
import 'package:flutter/material.dart';

class VistaConfiguracionImpresoraDeTickets extends StatelessWidget {
  const VistaConfiguracionImpresoraDeTickets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OpcionConfigurable(
            label: 'Nombre de la impresora',
            child: const Text('luis@bambucode.com')),
        OpcionConfigurable(
            label: 'Imprimir ticket', child: const Text('valor')),
      ],
    );
  }
}
