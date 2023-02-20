import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/icono_forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/pago_en_efectivo.dart';
import 'package:flutter/material.dart';

class ControlesFormasDePagoDesktop extends StatefulWidget {
  final Moneda totalACobrar;
  final Function(Pago pago) onPagoSeleccionado;

  const ControlesFormasDePagoDesktop({
    super.key,
    required this.onPagoSeleccionado,
    required this.totalACobrar,
  });

  @override
  State<ControlesFormasDePagoDesktop> createState() =>
      _ControlesFormasDePagoDesktopState();
}

class _ControlesFormasDePagoDesktopState
    extends State<ControlesFormasDePagoDesktop>
    with SingleTickerProviderStateMixin {
  late FormaDePago _formaPagoSeleccionada;
  final textEditController = TextEditingController();
  final consultas = ModuloVentas.repositorioConsultaVentas();

  @override
  void initState() {
    super.initState();
  }

  Future<List<FormaDePago>> _obtenerFormasDePago() async {
    var formasDePago = await consultas.obtenerFormasDePago();

    // Asignamos una forma de pago por defecto que será la primera
    _formaPagoSeleccionada = formasDePago.first;

    widget.onPagoSeleccionado(Pago.crear(
        forma: _formaPagoSeleccionada,
        monto: widget.totalACobrar,
        pagoCon: null));

    return formasDePago;
  }

  List<Widget> _mostrarFormasDePago(List<FormaDePago> formasDePago) {
    var resultado = <Widget>[];

    for (var formaDePago in formasDePago) {
      var tab = Tab(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconoFormaDePago(
              tipoFormaDePago: formaDePago.tipo,
              color: ColoresBase.primario600,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                formaDePago.nombre,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.normal,
                  color: ColoresBase.primario700,
                ),
              ),
            ),
          ],
        ),
      );
      resultado.add(tab);
    }

    return resultado;
  }

  List<Widget> _mostrarControlesDeFormaDePago(List<FormaDePago> formasDePago) {
    var resultado = <Widget>[];

    for (var formaDePago in formasDePago) {
      var controles = Container(
        color: ColoresBase.neutral100,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: PagoEnEfectivoWidget(
            formaDePago: formaDePago,
            textEditController: textEditController,
            // TODO: Asignar monto pagoCon tan pronto se salga del control
          ),
        ),
      );
      resultado.add(controles);
    }

    return resultado;
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

        return DefaultTabController(
          length: snapshot.data!.length,
          child: Column(children: [
            TabBar(
                indicatorColor: ColoresBase.primario600,
                automaticIndicatorColorAdjustment: false,
                onTap: (int index) {
                  _formaPagoSeleccionada = snapshot.data![index];

                  // Avisamos que se selecciono una forma de pago
                  widget.onPagoSeleccionado(Pago.crear(
                      forma: _formaPagoSeleccionada,
                      monto: widget.totalACobrar,
                      // TODO: Falta regresar este dato
                      pagoCon: null,
                      referencia: 'Referencia'));
                },
                tabs: _mostrarFormasDePago(snapshot.data!)),
            Expanded(
                child: TabBarView(
              children: _mostrarControlesDeFormaDePago(snapshot.data!),
            ))
          ]),
        );
      },
    );
  }
}
