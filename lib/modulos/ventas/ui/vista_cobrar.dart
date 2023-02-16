import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_text_field.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';
import 'package:eleventa/modulos/ventas/domain/pago.dart';
import 'package:eleventa/modulos/ventas/modulo_ventas.dart';
import 'package:flutter/material.dart';

class VistaCobrar extends StatelessWidget {
  final Moneda totalACobrar;
  final Function(Pago pago) onPagoSeleccionado;
  const VistaCobrar({
    Key? key,
    required this.totalACobrar,
    required this.onPagoSeleccionado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Sizes.p96,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                // TODO: Mostrar el total localizado
                totalACobrar.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: Sizes.p20,
                    fontWeight: FontWeight.w400,
                    color: ColoresBase.neutral500),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: ColoresBase.neutral50,
              child: _ControlesFormasDePago(
                totalACobrar: totalACobrar,
                onPagoSeleccionado: onPagoSeleccionado,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlesFormasDePago extends StatefulWidget {
  final Moneda totalACobrar;
  final Function(Pago pago) onPagoSeleccionado;
  const _ControlesFormasDePago({
    required this.onPagoSeleccionado,
    required this.totalACobrar,
  });

  @override
  State<_ControlesFormasDePago> createState() => _ControlesFormasDePagoState();
}

class _ControlesFormasDePagoState extends State<_ControlesFormasDePago>
    with SingleTickerProviderStateMixin {
  final textEditController = TextEditingController();
  final consultas = ModuloVentas.repositorioConsultaVentas();

  @override
  void initState() {
    //_tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Future<List<FormaDePago>> _obtenerFormasDePago() async {
    var formasDePago = await consultas.obtenerFormasDePago();

    // Avisamos que se selecciono la primer forma de pago
    widget.onPagoSeleccionado(Pago.crear(
        forma: formasDePago.first,
        monto: widget.totalACobrar,
        referencia: 'Referencia'));

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
            const Icon(
              Icons.attach_money_sharp,
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
                  fontFamily: 'Open Sans',
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
          child: Column(
            children: [
              ExTextField(
                hintText: formaDePago.tipo == TipoFormaDePago.efectivo
                    ? 'Pagó con'
                    : 'Referencia',
                controller: textEditController,
                width: 300,
              ),
              formaDePago.tipo == TipoFormaDePago.efectivo
                  ? const Text('Su Cambio: 0.00')
                  : const SizedBox()
            ],
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
                  widget.onPagoSeleccionado(Pago.crear(
                      forma: snapshot.data![index],
                      monto: widget.totalACobrar,
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
