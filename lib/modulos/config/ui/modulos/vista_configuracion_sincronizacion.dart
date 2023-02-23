import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/config/ui/opcion_configurable.dart';
import 'package:flutter/material.dart';

class VistaConfiguracionSincronizacion extends StatelessWidget {
  const VistaConfiguracionSincronizacion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // TODO: Incluir opciones reales de configuración de sincronizacion
        OpcionConfigurable(
          label: 'Ultima sincronización',
          child: Text(DateTime.now().toString()),
        ),
        OpcionConfigurable(
          label: 'GroupID',
          child: Text(UID().toString()),
        ),
        OpcionConfigurable(
          label: 'Cambios por sincronizar',
          child: const Text('12'),
        ),
      ],
    );
  }
}
