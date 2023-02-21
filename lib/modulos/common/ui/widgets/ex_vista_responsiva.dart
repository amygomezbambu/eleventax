import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

/// Despliega el [child] widget en un dialogo modal si el dispositivo es de escritorio
/// y en pantalla completa en una nueva vista (via Navigator.push) si el dispositivo es móvil.
///
/// El widget [child] debe regresar el valor de T cuando se presione el botón primario
/// asi como de desplegar su contenido de manera responsiva.
///
/// [titulo] se muestra como título del dialogo modal o como título de la vista mobile
/// [onBotonPrimarioTap] se ejecuta cuando se presiona el botón primario en desktop
/// [onBotonSecundarioTap] se ejecuta cuando se presiona el botón secundario en desktop
///
Future<T?> mostrarVistaResponsiva<T>({
  required BuildContext context,
  required String titulo,
  required Widget child,
  required String labelBotonPrimario,
  required String labelBotonSecundario,
  required Function(BuildContext ctx) onBotonPrimarioTap,
  required Function(BuildContext ctx) onBotonSecundarioTap,
  bool barrierDismissible = false,
  String? barrierLabel,
}) async {
  final esDesktop = LayoutValue(xs: false, md: true);

  if (esDesktop.resolve(context)) {
    return await showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        barrierColor: Colors.black38,
        builder: (BuildContext ctx) {
          return ExVistaResponsiva<T>.desktop(
            titulo: titulo,
            labelBotonPrimario: labelBotonPrimario,
            labelBotonSecundario: labelBotonSecundario,
            onBotonPrimarioTap: () => onBotonPrimarioTap(ctx),
            onBotonSecundarioTap: () => onBotonSecundarioTap(ctx),
            child: child,
          );
        });
  } else {
    var valor = await Navigator.of(context).push<T>(MaterialPageRoute(
      builder: (BuildContext ctx) {
        return ExVistaResponsiva<T>.mobile(
          titulo: 'Cobrar Venta',
          child: child,
        );
      },
    ));

    return valor;
  }
}

/// Representa una vista que se adapta de acuerdo a la resolución del dispositivo
/// en desktop el contenido se muestra con un dialogo modal con un botón primario y un botón secundario
/// en mobile el contenido se muestra como una nueva vista navegable de pantalla completa
///
/// Debe usarse por medio de la función [mostrarVistaResponsiva]
class ExVistaResponsiva<T> extends StatelessWidget {
  final String titulo;
  final Widget child;
  final String? labelBotonPrimario;
  final String? labelBotonSecundario;
  final VoidCallback? onBotonPrimarioTap;
  final VoidCallback? onBotonSecundarioTap;

  const ExVistaResponsiva.mobile({
    super.key,
    required this.titulo,
    required this.child,
    this.onBotonPrimarioTap,
    this.onBotonSecundarioTap,
    this.labelBotonPrimario,
    this.labelBotonSecundario,
  });

  const ExVistaResponsiva.desktop({
    super.key,
    required this.titulo,
    required this.child,
    required this.onBotonPrimarioTap,
    required this.onBotonSecundarioTap,
    required this.labelBotonPrimario,
    required this.labelBotonSecundario,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      xs: (context) => Scaffold(
          appBar: ExAppBar(
            titleText: titulo,
            centerTitle: true,
          ),
          body: child),
      md: (context) => DialogoModalDesktop<T>(
        titulo: titulo,
        botones: [
          // TODO: UI - Pasar como parametro el icono y ancho de los botones?
          ExBoton.secundario(
            width: 150,
            icon: Icons.arrow_back,
            colorBoton: Colors.white,
            label: labelBotonSecundario ?? 'Regresar',
            onTap: onBotonSecundarioTap!,
          ),
          ExBoton.primario(
            width: 300,
            icon: Iconos.cart_upload,
            label: labelBotonPrimario ?? 'Aceptar',
            onTap: onBotonPrimarioTap!,
          ),
        ],
        child: child,
      ),
    );
  }
}

class DialogoModalDesktop<T> extends StatefulWidget {
  final String titulo;
  final Widget child;
  final List<Widget> botones;

  const DialogoModalDesktop({
    super.key,
    required this.titulo,
    required this.child,
    required this.botones,
  });

  @override
  State<StatefulWidget> createState() => DialogoModalDesktopState();
}

class DialogoModalDesktopState<T> extends State<DialogoModalDesktop<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.decelerate);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(scaleAnimation),
          child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.only(top: 0.0),

              // TODO: Verificar que en vistas desktop mas pequeñas el espacio sea suficiente
              height: Sizes.p96 * 1.4,
              width: Sizes.p96 * 1.8,
              decoration: BoxDecoration(
                  color: ColoresBase.neutral200,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        offset: Offset(5, 5),
                        blurRadius: 10)
                  ]),
              child: Column(
                children: <Widget>[
                  Expanded(
                      flex: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: ColoresBase.neutral50,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(11.0)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                              ),
                              child: SizedBox(
                                height: 20,
                                child: Text(widget.titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: ColoresBase.neutral500,
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                            ),
                            widget.child,
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 0.0,
                      right: 0.0,
                      top: 0.0,
                      bottom: 0.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(top: 0),
                      decoration: BoxDecoration(
                        color: ColoresBase.neutral200,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: widget.botones,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
