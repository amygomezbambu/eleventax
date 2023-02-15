import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/ventas/ui/venta_provider.dart';
import 'package:flutter/material.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/boton_accion_de_venta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccionesDeVenta extends ConsumerWidget {
  final FocusNode focusNode;

  const AccionesDeVenta({
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventaEnProgreso = ref.watch(providerVenta);
    final notifierVenta = ref.read(providerVenta.notifier);

    void ejecutarEnfocarControlCodigo(Function funcion) {
      funcion();

      if (focusNode.children.first.canRequestFocus) {
        focusNode.children.first.requestFocus();
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.p2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              BotonAccionDeVenta(
                label: 'Aumentar',
                hintText: 'Suma 1 unidad al artículo seleccionado',
                atajoTeclado: '+',
                icon: Iconos.cart_add,
                enabled: ventaEnProgreso.venta.articulos.isNotEmpty,
                onTap: () => {
                  ejecutarEnfocarControlCodigo(notifierVenta.aumentarCantidad)
                },
              ),
              BotonAccionDeVenta(
                label: 'Disminuir',
                hintText: 'Resta 1 unidad al articulo seleccionado',
                atajoTeclado: '-',
                icon: Iconos.cart_minus,
                enabled: ventaEnProgreso.venta.articulos.isNotEmpty,
                onTap: () => {
                  ejecutarEnfocarControlCodigo(notifierVenta.disminuirCantidad)
                },
              )
            ],
          ),
          Row(
            children: [
              BotonAccionDeVenta(
                label: 'Varios',
                hintText: 'Ingresa la cantidad del artículo manualmente',
                icon: Iconos.box,
                atajoTeclado: 'INS',
                // TODO: Implementar
                enabled: false, //ventaEnProgreso.venta.articulos.isNotEmpty,
                onTap: () => {},
              ),
              BotonAccionDeVenta(
                label: 'Eliminar',
                hintText: 'Remover el artículo seleccionado de la venta',
                atajoTeclado: 'DEL',
                icon: Iconos.cart_cancel,
                // TODO: Implementar
                enabled: false, //ventaEnProgreso.venta.articulos.isNotEmpty,
                onTap: () => {},
              )
            ],
          ),
          // Row(
          //   children: const [
          //     BotonAccionDeVenta('Venta Rápida', Icons.person),
          //     BotonAccionDeVenta('Asignar Cliente', Icons.person)
          //   ],
          // ),
          // Row(
          //   children: const [
          //     BotonAccionDeVenta('Aplicar Descuento', Icons.person),
          //     BotonAccionDeVenta('Convertir a \n cotización', Icons.person)
          //   ],
          // )
        ],
      ),
    );
  }
}
