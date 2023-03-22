import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';
import 'package:flutter/material.dart';

class DetalleTransaccion extends StatefulWidget {
  final UID ventaUid;

  const DetalleTransaccion({super.key, required this.ventaUid});

  @override
  State<DetalleTransaccion> createState() => _DetalleTransaccionState();
}

class _DetalleTransaccionState extends State<DetalleTransaccion> {
  @override
  void initState() {
    super.initState();
  }

  Future<VentaDto> _leerDetalleDeVenta(UID ventaUid) async {
    // Simulamos una lectura de la base de datos lenta
    await Future.delayed(const Duration(seconds: 1));

    final demoData = VentaDto();
    demoData.folio = '1000';

    return demoData;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Integrar aqui la lectura del detalle de la venta
    return FutureBuilder<VentaDto>(
      future: _leerDetalleDeVenta(widget.ventaUid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final venta = snapshot.data!;

          return Column(children: [
            Text('Botones para venta ${venta.folio}'),
            const Card(
              child: Text('Detalle de venta'),
            ),
            const Text('totales'),
            Text(venta.total.toString()),
          ]);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
