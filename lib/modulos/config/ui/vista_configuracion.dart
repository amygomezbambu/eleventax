import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:flutter/material.dart';

class VistaConfiguracion extends StatelessWidget {
  const VistaConfiguracion({super.key});

  Future<void> forceSync() async {
    // var obtenerVentas = ObtainRemoteChanges.instance;

    // obtenerVentas.request.singleRequest = true;
    // await obtenerVentas.exec().catchError((e) {
    //   //print('Error desde la UI ${e.toString()}');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ExAppBar(),
      body: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async => await forceSync(),
          ),
        ],
      ),
    );
  }
}
