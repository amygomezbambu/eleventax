import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:flutter/material.dart';

class ExDialogoResponsivo<T> extends StatefulWidget {
  final String titulo;
  final Widget child;
  final VoidCallback onBotonPrimarioTap;
  final VoidCallback onBotonSecundarioTap;

  const ExDialogoResponsivo({
    super.key,
    required this.titulo,
    required this.child,
    required this.onBotonPrimarioTap,
    required this.onBotonSecundarioTap,
  });

  @override
  State<StatefulWidget> createState() => ExDialogoResponsivoState();
}

class ExDialogoResponsivoState<T> extends State<ExDialogoResponsivo<T>>
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
                          children: [
                            ExBoton.secundario(
                              width: 150,
                              icon: Icons.arrow_back,
                              colorBoton: Colors.white,
                              label: 'Cancelar',
                              onTap: widget.onBotonSecundarioTap,
                              // onTap: () {
                              //   // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
                              //   // rootNavigator para que el dialogo se cierre y no la vista anterior
                              //   Navigator.of(context, rootNavigator: true)
                              //       .pop(false);
                              // },
                            ),
                            ExBoton.primario(
                              width: 300,
                              icon: Iconos.cart_upload,
                              label: 'Cobrar',
                              onTap: widget.onBotonPrimarioTap,
                            ),
                          ],
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
