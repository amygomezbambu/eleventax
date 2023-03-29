import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

enum TipoAccionPrimaria {
  normal,
  destructiva,
}

/// Representa las acciones de un diálogo, el botón de accion primaria (agregar, aceptar, etc)
/// y el botón de acción secundaria (cancelar, etc)
/// Muestra los botones en una fila en dispositivos de escritorio y en una columna en dispositivos móviles
/// siguiendo el Design System de eleventa
class ExAccionesDeDialogo extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String accionPrimariaLabel;
  final TipoAccionPrimaria tipoAccionPrimaria;
  final String accionSecundariaLabel;
  final VoidCallback onTapAccionPrimaria;
  final VoidCallback onTapAccionSecundaria;

  ExAccionesDeDialogo({
    super.key,
    required this.accionPrimariaLabel,
    this.tipoAccionPrimaria = TipoAccionPrimaria.normal,
    this.accionSecundariaLabel = 'Cancelar',
    required this.onTapAccionPrimaria,
    required this.onTapAccionSecundaria,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p4),
      height: !esDesktop.resolve(context) ? Sizes.p32 : null,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
        ),
      ),
      child: Flex(
        verticalDirection: esDesktop.resolve(context)
            ? VerticalDirection.down
            : VerticalDirection.up,
        direction: esDesktop.resolve(context) ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ExBoton.secundario(
              icon: Icons.arrow_back,
              label: accionSecundariaLabel,
              onTap: onTapAccionSecundaria,
            ),
          ),
          SizedBox(
            width: esDesktop.resolve(context) ? Sizes.p2 : null,
            height: !esDesktop.resolve(context) ? Sizes.p2 : null,
          ),
          Expanded(
            child: ExBoton.primario(
              icon: Iconos.cart_add,
              colorBoton: (tipoAccionPrimaria == TipoAccionPrimaria.destructiva)
                  ? ColoresBase.red300
                  : Colores.accionPrimaria,
              colorIcono: (tipoAccionPrimaria == TipoAccionPrimaria.destructiva)
                  ? ColoresBase.yellow200
                  : ColoresBase.white,
              colorTexto: (tipoAccionPrimaria == TipoAccionPrimaria.destructiva)
                  ? ColoresBase.white
                  : ColoresBase.white,
              label: accionPrimariaLabel,
              onTap: onTapAccionPrimaria,
            ),
          ),
        ],
      ),
    );
  }
}
