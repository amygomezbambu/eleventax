import 'package:flutter/material.dart';

/// Vista simple usada para cuando NO se encuentra una ruta
/// en teoria, NUNCA debe aparecerle a un usuario
class VistaNoEncontrado extends StatelessWidget {
  const VistaNoEncontrado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Text('No se encontró la ruta'),
    );
  }
}
