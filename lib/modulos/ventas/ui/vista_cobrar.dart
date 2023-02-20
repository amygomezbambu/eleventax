import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/formas_de_pago_desktop.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/formas_de_pago_mobile.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class VistaCobrar extends StatelessWidget {
  final _esDesktop = LayoutValue(xs: false, md: true);
  final Moneda totalACobrar;

  /// Se manda llamar cuando se selecciona una forma de pago en la UI
  /// en desktop esto sucede cada que se cambia de tab
  final Function(Pago pago) onPagoSeleccionado;

  /// Se lanza cuando en mobile se selecciona una forma de pago lo cual concluye
  /// el proceso de cobro
  final Function() onCobroConcluido;

  VistaCobrar({
    Key? key,
    required this.totalACobrar,
    required this.onPagoSeleccionado,
    required this.onCobroConcluido,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _esDesktop.resolve(context) ? Sizes.p96 : double.infinity,
      width: _esDesktop.resolve(context) ? null : double.infinity,
      child: Column(
        children: [
          _esDesktop.resolve(context)
              ? Expanded(
                  flex: 2,
                  child: TotalVentaWidget(
                      totalACobrar: totalACobrar, esDesktop: _esDesktop),
                )
              : TotalVentaWidget(
                  totalACobrar: totalACobrar, esDesktop: _esDesktop),
          _esDesktop.resolve(context)
              ? Expanded(
                  flex: 4,
                  child: Container(
                      color: ColoresBase.neutral50,
                      child: ControlesFormasDePagoDesktop(
                        totalACobrar: totalACobrar,
                        onPagoSeleccionado: onPagoSeleccionado,
                      )),
                )
              : ControlesFormasDePagoMobile(
                  totalACobrar: totalACobrar,
                  onCobroConcluido: (Pago pago) {
                    // En Mobile lanzamos los dos eventos, primero el que
                    // se selecciono una forma de pago y luego el de cobro concluido
                    onPagoSeleccionado(pago);
                    onCobroConcluido();
                  },
                ),
        ],
      ),
    );
  }
}

class TotalVentaWidget extends StatelessWidget {
  const TotalVentaWidget({
    super.key,
    required this.totalACobrar,
    required LayoutValue<bool> esDesktop,
  }) : _esDesktop = esDesktop;

  final Moneda totalACobrar;
  final LayoutValue<bool> _esDesktop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        // TODO: Mostrar el total localizado
        totalACobrar.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: 'Inter',
            fontSize: _esDesktop.resolve(context) ? Sizes.p20 : Sizes.p16,
            fontWeight: FontWeight.w400,
            color: ColoresBase.neutral500),
      ),
    );
  }
}
