import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_acciones_dialogo.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class ExDialogos {
  /// Muestra un dialogo con un título, un icono y una lista de widgets
  static Future<void> mostrarAdvertencia(context,
      {required String titulo, String mensaje = ''}) async {
    return await ExDialogos.mostrarDialogo<void>(context,
        titulo: titulo,
        icono: Icons.warning,
        widgets: [
          titulo.isNotEmpty
              ? Padding(
                  padding:
                      const EdgeInsets.only(top: Sizes.p4, bottom: Sizes.p4),
                  child: Text(mensaje,
                      style: const TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: TextSizes.textSm,
                          fontWeight: FontWeight.normal,
                          color: ColoresBase.neutral700)),
                )
              : const Center(),
          ExBoton.secundario(
            icon: Icons.arrow_back,
            label: 'Regresar!',
            onTap: () {
              // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
              // rootNavigator para que el dialogo se cierre y no la vista anterior
              Navigator.of(context, rootNavigator: true).pop();
              return;
            },
          )
        ]);
  }

  /// Muestra un dialogo de confirmacion al usuario para una acción de eliminación
  /// de registros, acentuando los botones e iconos para reflejar la acción.
  /// - Desktop - Se posiciona en el centro de la pantalla
  /// - Mobile  - Se posiciona en la parte inferior de la pantalla
  /// Si el usuario eligió eliminar el registro, regresa un [[true]], de lo contrario [[false]]
  static Future<bool?> mostrarConfirmacionEliminar(context,
      {required String titulo,
      String mensaje = '',
      String textoBotonEliminar = 'Eliminar'}) async {
    return await ExDialogos.mostrarDialogo<bool>(
      titulo: titulo,
      mensaje: mensaje,
      icono: Iconos.trash,
      esAccionDestructiva: true,
      context,
      widgets: [
        ExAccionesDeDialogo(
          accionPrimariaLabel: textoBotonEliminar,
          tipoAccionPrimaria: TipoAccionPrimaria.destructiva,
          onTapAccionPrimaria: () {
            // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
            // rootNavigator para que el dialogo se cierre y no la vista anterior
            Navigator.of(context, rootNavigator: true).pop(true);
          },
          onTapAccionSecundaria: () {
            // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
            // rootNavigator para que el dialogo se cierre y no la vista anterior
            Navigator.of(context, rootNavigator: true).pop(false);
          },
        ),
      ],
    );
  }

  /// Muestra un dialogo de confirmacion al usuario para una acción de
  /// de registros, acentuando los botones e iconos para reflejar la acción.
  /// - Desktop - Se posiciona en el centro de la pantalla
  /// - Mobile  - Se posiciona en la parte inferior de la pantalla
  /// Si el usuario eligió la acción primaria, regresa un [[true]], de lo contrario [[false]]
  static Future<T?> mostrarDialogo<T extends Object?>(
    context, {
    required String titulo,
    String? mensaje,
    required IconData icono,
    required List<Widget> widgets,
    bool esAccionDestructiva = false,
  }) async {
    final esDesktop = LayoutValue(xs: false, md: true);

    return await showGeneralDialog<T>(
      context: context,
      barrierLabel: 'dialogo',
      barrierDismissible: true,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Align(
            alignment: esDesktop.resolve(context)
                ? Alignment.center
                : Alignment.bottomCenter,
            child: Container(
              width: esDesktop.resolve(context) ? Sizes.p96 * 1.2 : null,
              margin: const EdgeInsets.only(
                  bottom: Sizes.p4, left: Sizes.p3, right: Sizes.p3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(DesignSystem.tamanoRoundedCorners),
              ),
              child: Wrap(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DialogoEncabezado(
                        titulo: titulo,
                        mensaje: mensaje,
                        icono: icono,
                        esAccionDestructiva: esAccionDestructiva,
                      ),
                      Column(
                        children: widgets,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
    );
  }
}

class DialogoEncabezado extends StatelessWidget {
  final String titulo;
  final String? mensaje;
  final IconData icono;
  final bool esAccionDestructiva;

  const DialogoEncabezado({
    super.key,
    required this.titulo,
    this.esAccionDestructiva = false,
    this.mensaje,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: ColoresBase.neutral200,
          ),
        ),
      ),
      padding: const EdgeInsets.only(
        left: Sizes.p4,
        right: Sizes.p4,
        bottom: Sizes.p4,
        top: Sizes.p1,
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DialogoTitulo(
                titulo: titulo,
                mensaje: mensaje,
                icono: icono,
                esAccionDestructiva: esAccionDestructiva,
              ),
            ),
            SizedBox(
              width: Sizes.p9,
              height: Sizes.p9,
              child: IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(
                  Icons.close,
                  size: Sizes.p5,
                  color: ColoresBase.neutral700,
                ),
                onPressed: () {
                  // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
                  // rootNavigator para que el dialogo se cierre y no la vista anterior
                  Navigator.of(context, rootNavigator: true).pop();
                  return;
                },
              ),
            )
          ]),
    );
  }
}

class DialogoTitulo extends StatelessWidget {
  final esDesktop = LayoutValue(xs: false, md: true);
  final String titulo;
  final String? mensaje;
  final IconData icono;
  final bool esAccionDestructiva;

  DialogoTitulo({
    super.key,
    required this.titulo,
    required this.esAccionDestructiva,
    this.mensaje,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: esDesktop.resolve(context) ? Sizes.p4 : Sizes.p0,
      ),
      child: Flex(
        direction: esDesktop.resolve(context) ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: esDesktop.resolve(context)
            ? MainAxisAlignment.start
            : MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: Sizes.p2,
              top: !esDesktop.resolve(context) ? Sizes.p3 : Sizes.p0,
              bottom: !esDesktop.resolve(context) ? Sizes.p2 : Sizes.p0,
            ),
            child: CircleAvatar(
              backgroundColor: esAccionDestructiva
                  ? Colors.red[50]
                  : ColoresBase.primario200,
              child: Icon(
                icono,
                color: esAccionDestructiva
                    ? ColoresBase.red300
                    : ColoresBase.primario600,
                size: Sizes.p5,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: esDesktop.resolve(context)
                          ? TextSizes.textSm
                          : TextSizes.textBase,
                      color: ColoresBase.neutral800,
                      fontWeight: FontWeight.w600)),
              mensaje != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: Sizes.p2),
                      child: Text(mensaje!,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: esDesktop.resolve(context)
                                ? TextSizes.textXs
                                : TextSizes.textSm,
                            color: ColoresBase.neutral600,
                            fontWeight: FontWeight.w400,
                          )),
                    )
                  : const Center(),
            ],
          )
        ],
      ),
    );
  }
}
