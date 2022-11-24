import 'package:flutter/material.dart';

class SyncConfigPage extends StatelessWidget {
  const SyncConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> forceSync() async {
      // var obtenerVentas = ObtainRemoteChanges.instance;

      // obtenerVentas.request.singleRequest = true;
      // await obtenerVentas.exec().catchError((e) {
      //   //print('Error desde la UI ${e.toString()}');
      // });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Sincronización'),
      ),
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
