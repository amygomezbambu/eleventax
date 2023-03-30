import 'package:eleventa/datos_demo.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:eleventa/modulos/config/ui/opcion_configurable.dart';
import 'package:flutter/material.dart';

class VistaConfiguracionCuenta extends StatelessWidget {
  const VistaConfiguracionCuenta({Key? key}) : super(key: key);

  Future<void> _insertarDatosDemostracion() async {
    var datosDemo = DatosDemo();
    await datosDemo.insertarDatosDemoAbarrotes();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // OpcionConfigurable(
        //   label: 'Correo electrónico',
        //   textoAyuda: 'Tu cuenta de mieleventa.com',
        //   child: const Text('luis@bambucode.com'),
        // ),
        // OpcionConfigurable(
        //   label: 'Negocio',
        //   child: const Text('Super Chihuas'),
        // ),
        // OpcionConfigurable(
        //   label: 'Sucursal',
        //   child: const Text('Matriz'),
        // ),
        OpcionConfigurable(
          label: 'Demostración',
          child: ExBoton.secundario(
            label: 'Llenar con datos de demostración',
            icon: Icons.add_to_photos,
            width: 100,
            onTap: () {
              _insertarDatosDemostracion();
            },
          ),
        ),
      ],
    );
  }
}
