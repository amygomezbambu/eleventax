import 'package:eleventa/modulos/common/ui/widgets/ex_vista_principal_scaffold.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/venta_actual.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:eleventa/l10n/generated/l10n.dart';

class VistaVentas extends StatefulWidget {
  const VistaVentas({Key? key, required String title}) : super(key: key);

  @override
  State<VistaVentas> createState() => _VistaVentasState();
}

class _VistaVentasState extends State<VistaVentas> {
  @override
  Widget build(BuildContext ctx) {
    var m = L10n.of(context);

    return VistaPrincipalScaffold(
      titulo: m.ventas_titulo,
      child: AdaptiveBuilder(
        xs: (context) => Column(
          children: [VentaActual()],
        ),
        md: (context) => Row(
          children: [
            Expanded(
              child: Row(
                children: [VentaActual()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
