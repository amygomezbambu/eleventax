import 'package:eleventa/modulos/common/ui/widgets/ex_vista_maestro_detalle.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/transacciones/ui/widgets/detalle_transaccion.dart';
import 'package:eleventa/modulos/transacciones/ui/widgets/transaccion_de_venta_list_item.dart';
<<<<<<< HEAD
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
=======
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter/material.dart';

class VistaTransacciones extends StatelessWidget {
  const VistaTransacciones({super.key});

  // TODO: Verificar si es correcto usar para el listado VentaDTO o es mejor otro DTO más eficiente que solo tenga los datos
  // necesarios para el listado de venta: cobrado_en, folio, total, forma de pago, resumen articulos, etc.
  Future<List<VentaDto>> _leerListadoDeVentas() async {
    // Simulamos una lectura de la base de las transacciones del dia
    await Future.delayed(const Duration(seconds: 1));

<<<<<<< HEAD
    var ventas = <VentaDto>[];
    final consultas = ModuloVentas.repositorioConsultaVentas();
    ventas = await consultas.obtenerVentasPorDia();
    
    return ventas;
=======
    var res = <VentaDto>[];
    for (var i = 0; i < 100; i++) {
      final demoData = VentaDto();
      demoData.folio = i.toString();
      res.add(demoData);
    }
    return res;
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VentaDto>>(
      future: _leerListadoDeVentas(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var listadoVentas = snapshot.data!;

          var ventas = <TransaccionDeVentaListItem>[];

          // Creamos el listado de items para el maestro detalle
          for (var venta in listadoVentas) {
            ventas.add(TransaccionDeVentaListItem(
                label: 'Venta ${venta.folio}',
                venta: venta,
                child: DetalleTransaccion(
                  title: 'Venta ${venta.folio}',
<<<<<<< HEAD
                  ventaUid: UID.fromString(venta.uid),
                  venta: venta,
=======
                  ventaUid: UID(),
>>>>>>> d883161 (feat - Se termina vista de transacciones de ventas (#479))
                )));
          }

          return ExVistaMaestroDetalle(
            title: 'Ventas del día',
            items: ventas,
          );
        } else {
          return const ExVistaMaestroDetalle(
            title: 'Ventas del día',
            items: [],
          );
        }
      },
    );
  }
}
