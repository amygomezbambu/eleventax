import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/config/ui/opcion_configurable.dart';
import 'package:flutter/material.dart';

class VistaConfiguracionVentas extends StatefulWidget {
  const VistaConfiguracionVentas({Key? key}) : super(key: key);

  @override
  State<VistaConfiguracionVentas> createState() =>
      _VistaConfiguracionVentasState();
}

class _VistaConfiguracionVentasState extends State<VistaConfiguracionVentas> {
  final TextEditingController _prefijoController = TextEditingController();
  final TextEditingController _folioController = TextEditingController();
  final _prefijoKey = GlobalKey<FormFieldState<String>>();
  final _paddingCampos = const EdgeInsets.only(bottom: 10, top: 10);

  @override
  void initState() {
    super.initState();
    // TODO: Leer prefijo de la configuracion actual
    _prefijoController.text = '1';
  }

  Future<String?> _validarPrefijo(String? value) async {
    if ((value == null) || (value.isEmpty)) {
      return 'El prefijo no puede ser vacio';
    }

    return null;
  }

  Future<void> _guardarPrefijo(String? value) async {
    if (await _validarPrefijo(value) == null) {
      //print('Guardando nuevo prefijo: $value ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OpcionConfigurable(
          label: 'Prefijo',
          textoAyuda:
              'Texto único que se usa como prefijo del folio numérico de las ventas',
          padding: _paddingCampos,
          child: ExTextField(
            aplicarResponsividad: false,
            fieldKey: _prefijoKey,
            hintText: 'Prefijo de los folios de la venta',
            width: Sizes.p72,
            controller: _prefijoController,
            onFieldSubmitted: _guardarPrefijo,
            onExit: () async {
              await _guardarPrefijo(_prefijoController.text);
            },
            validator: _validarPrefijo,
          ),
        ),
        OpcionConfigurable(
          label: 'Folio actual',
          padding: _paddingCampos,
          child: ExTextField(
            aplicarResponsividad: false,
            hintText: 'Folio actual',
            inputType: InputType.numerico,
            width: Sizes.p72,
            controller: _folioController,
          ),
        ),
      ],
    );
  }
}
