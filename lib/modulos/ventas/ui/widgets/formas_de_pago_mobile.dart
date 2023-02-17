import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/icono_forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/pago_en_efectivo.dart';
import 'package:flutter/material.dart';

class ControlesFormasDePagoMobile extends StatefulWidget {
  final Moneda totalACobrar;
  final Function(Pago pago) onCobroConcluido;

  const ControlesFormasDePagoMobile({
    super.key,
    required this.totalACobrar,
    required this.onCobroConcluido,
  });

  @override
  State<ControlesFormasDePagoMobile> createState() =>
      _ControlesFormasDePagoMobileState();
}

class _ControlesFormasDePagoMobileState
    extends State<ControlesFormasDePagoMobile> {
  final textEditController = TextEditingController();
  final consultas = ModuloVentas.repositorioConsultaVentas();

  @override
  void initState() {
    super.initState();
  }

  Future<List<FormaDePago>> _obtenerFormasDePago() async {
    return await consultas.obtenerFormasDePago();
  }

  /// En mobile cuando se hace tap en un botón eso concluye el proceso de cobro
  Future<void> _procesarFormaPagoElegida(FormaDePago formaDePago) async {
    Moneda? pagoConEfectivo;
    // TODO: Si es efectivo mandamos a una segunda vista
    if (formaDePago.tipo == TipoFormaDePago.efectivo) {
      pagoConEfectivo =
          await Navigator.of(context).push<Moneda>(MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: const ExAppBar(
              titleText: 'Pago en efectivo',
              centerTitle: true,
            ),
            body: Container(
              padding: const EdgeInsets.all(20),
              child: PagoEnEfectivoWidget(
                  formaDePago: formaDePago,
                  textEditController: textEditController),
            ),
          );
        },
      ));

      if (pagoConEfectivo == null) {
        return;
      }
    }

    debugPrint(
        'Regresando pago de $formaDePago, pagoConEfectivo: $pagoConEfectivo');
    var pago = Pago.crear(
        forma: formaDePago,
        monto: widget.totalACobrar,
        pagoCon: pagoConEfectivo,
        referencia: textEditController.text);

    widget.onCobroConcluido(pago);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _obtenerFormasDePago(),
      builder:
          (BuildContext context, AsyncSnapshot<List<FormaDePago>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Expanded(
          child: Column(
            children: [
              for (var formaPago in snapshot.data!)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 15.0, left: 20, right: 20),
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(65),
                        backgroundColor: ColoresBase.primario200,
                        padding: const EdgeInsets.all(5),
                        foregroundColor: ColoresBase.primario700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        side: const BorderSide(
                            color: ColoresBase.primario300, width: Sizes.px),
                      ),
                      onPressed: () => _procesarFormaPagoElegida(formaPago),
                      icon: IconoFormaDePago(tipoFormaDePago: formaPago.tipo),
                      label: Text(
                        formaPago.nombre,
                        style: const TextStyle(
                            fontSize: TextSizes.textSm,
                            fontWeight: FontWeight.normal,
                            color: ColoresBase.neutral600),
                      )),
                )
            ],
          ),
        );
      },
    );
  }
}
