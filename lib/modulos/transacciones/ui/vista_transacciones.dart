import 'package:eleventa/modulos/common/ui/vista_maestro_detalle_responsiva.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/transacciones/ui/widgets/detalle_transaccion.dart';
import 'package:eleventa/modulos/transacciones/ui/widgets/transaccion_de_venta.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter/material.dart';

class VistaTransacciones extends StatelessWidget {
  const VistaTransacciones({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Verificar si es correcto usar para el listado VentaDTO o es mejor otro DTO más eficiente que solo tenga los datos
    // necesarios para el listado de venta: cobrado_en, folio, total, forma de pago, resumen articulos, etc.
    Future<List<VentaDto>> _leerListadoDeVentas() async {
      // Simulamos una lectura de la base de las transacciones del dia
      await Future.delayed(const Duration(seconds: 1));

      final demoData = VentaDto();
      demoData.folio = '1000';

      return [demoData, demoData, demoData];
    }

    return FutureBuilder<List<VentaDto>>(
      future: _leerListadoDeVentas(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final listadoVentas = snapshot.data!;

          var items = <TransaccionDeVenta>[];

          // Creamos el listado de items para el maestro detalle
          for (var venta in listadoVentas) {
            items.add(TransaccionDeVenta(
                label: 'Venta ${venta.folio}',
                icon: Icons.shopping_cart,
                child: DetalleTransaccion(
                  ventaUid: UID(),
                )));
          }

          return VistaMeaestroDetalleResponsiva(
            titulo: 'Ventas del día',
            items: items,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
