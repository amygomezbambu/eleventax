import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton_secundario.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

class ExDialogos {
  static Future<void> mostrarAdvertencia(context,
      {required String titulo, String mensaje = ''}) async {
    return await ExDialogos.mostrarDialogo<void>(context, widgets: [
      const Padding(
          padding: EdgeInsets.all(Sizes.p2_5),
          child: CircleAvatar(
            backgroundColor: ColoresBase.primario200,
            child: Icon(
              Iconos.information,
              color: ColoresBase.primario600,
              size: Sizes.p6,
            ),
          )),
      Text(titulo,
          style: const TextStyle(
              fontSize: TextSizes.textBase,
              decoration: TextDecoration.none,
              color: ColoresBase.neutral800,
              fontWeight: FontWeight.w600)),
      titulo.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: Sizes.p4, bottom: Sizes.p4),
              child: Text(mensaje,
                  style: const TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: TextSizes.textSm,
                      fontWeight: FontWeight.normal,
                      color: ColoresBase.neutral700)),
            )
          : const Center(),
      ExBotonSecundario(
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
    return await ExDialogos.mostrarDialogo<bool>(context, widgets: [
      const Padding(
          padding: EdgeInsets.all(Sizes.p2_5),
          child: CircleAvatar(
            backgroundColor: ColoresBase.yellow100,
            child: Icon(
              Iconos.information,
              color: ColoresBase.yellow900,
              size: Sizes.p6,
            ),
          )),
      Padding(
        padding: const EdgeInsets.all(Sizes.p2),
        child: Text(titulo,
            style: const TextStyle(
                decoration: TextDecoration.none,
                fontSize: TextSizes.textBase,
                color: ColoresBase.neutral800,
                fontWeight: FontWeight.w600)),
      ),
      mensaje.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: Sizes.p1, bottom: Sizes.p1),
              child: Text(mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: TextSizes.textSm,
                      fontWeight: FontWeight.normal,
                      color: ColoresBase.neutral700)),
            )
          : const Center(),
      const SizedBox(
        height: Sizes.p2,
      ),
      ExBotonPrimario(
        icon: Iconos.trash,
        colorBoton: ColoresBase.yellow900,
        colorIcono: ColoresBase.yellow100,
        label: textoBotonEliminar,
        onTap: () {
          // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
          // rootNavigator para que el dialogo se cierre y no la vista anterior
          Navigator.of(context, rootNavigator: true).pop(true);
        },
      ),
      const SizedBox(
        height: Sizes.p2,
      ),
      ExBotonSecundario(
        icon: Icons.arrow_back,
        label: 'Regresar',
        onTap: () {
          // NOTA: Ya que usamos GoRouter tenemos que especificar el parámetro
          // rootNavigator para que el dialogo se cierre y no la vista anterior
          Navigator.of(context, rootNavigator: true).pop(false);
        },
      ),
    ]);
  }

  /// Muestra un dialogo de confirmacion al usuario para una acción de eliminación
  /// de registros, acentuando los botones e iconos para reflejar la acción.
  /// - Desktop - Se posiciona en el centro de la pantalla
  /// - Mobile  - Se posiciona en la parte inferior de la pantalla
  /// Si el usuario eligió eliminar el registro, regresa un [[true]], de lo contrario [[false]]
  static Future<T?> mostrarDialogo<T extends Object?>(context,
      {required List<Widget> widgets}) async {
    final esDesktop = LayoutValue(xs: false, md: true);

    return await showGeneralDialog<T>(
      context: context,
      barrierLabel: 'dialogo',
      barrierDismissible: true,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: esDesktop.resolve(context)
              ? Alignment.center
              : Alignment.bottomCenter,
          child: Container(
            width: esDesktop.resolve(context) ? Sizes.p96 : null,
            margin: const EdgeInsets.only(
                bottom: Sizes.p16, left: Sizes.p3, right: Sizes.p3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(DesignSystem.tamanoRoundedCorners),
            ),
            child: Container(
              padding: const EdgeInsets.all(Sizes.p4),
              child: Wrap(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widgets,
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
