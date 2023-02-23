import 'package:eleventa/modulos/config/ui/modulos/vista_configuracion_cuenta.dart';
import 'package:eleventa/modulos/config/ui/modulos/vista_configuracion_dispositivos.dart';
import 'package:eleventa/modulos/config/ui/modulos/vista_configuracion_sincronizacion.dart';
import 'package:eleventa/modulos/config/ui/modulos/vista_configuracion_ventas.dart';
import 'package:flutter/material.dart';

class OpcionDeConfiguracion {
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Widget vista;

  const OpcionDeConfiguracion({
    required this.nombre,
    this.descripcion = '',
    required this.icono,
    required this.vista,
  });
}

class ConfiguracionDeModulo {
  final String nombre;
  final String descripcion;
  final IconData icono;
  final List<OpcionDeConfiguracion> configuraciones;

  const ConfiguracionDeModulo({
    required this.nombre,
    this.descripcion = '',
    required this.icono,
    required this.configuraciones,
  });
}

// TODO: Extraer esto en otro archivo y/o ver cómo cada modulo
// exponga sus opciones configurables y widget y aqui solo se lean
var configuracion = <ConfiguracionDeModulo>[
  const ConfiguracionDeModulo(
      nombre: 'General',
      icono: Icons.person,
      configuraciones: [
        OpcionDeConfiguracion(
          nombre: 'Cuenta',
          icono: Icons.account_circle_outlined,
          vista: VistaConfiguracionCuenta(),
        ),
        OpcionDeConfiguracion(
          nombre: 'Sincronización',
          icono: Icons.monitor_heart_outlined,
          vista: VistaConfiguracionSincronizacion(),
        ),
      ]),
  ConfiguracionDeModulo(
      nombre: 'Ventas',
      icono: Icons.person,
      configuraciones: [
        OpcionDeConfiguracion(
          nombre: 'Folio de Ventas',
          icono: Icons.numbers_rounded,
          vista: VistaConfiguracionVentas(),
        ),
        const OpcionDeConfiguracion(
          nombre: 'Formas de Pago',
          icono: Icons.payments_outlined,
          vista: Text('Configurar Formas de pago'),
        ),
      ]),
  const ConfiguracionDeModulo(
      nombre: 'Impresión',
      icono: Icons.person,
      configuraciones: [
        OpcionDeConfiguracion(
          nombre: 'Impresora de tickets',
          icono: Icons.local_printshop_rounded,
          vista: VistaConfiguracionImpresoraDeTickets(),
        ),
        OpcionDeConfiguracion(
          nombre: 'Configuración de Ticket',
          icono: Icons.file_copy,
          vista: VistaConfiguracionImpresoraDeTickets(),
        ),
      ]),
];
