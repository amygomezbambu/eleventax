import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

/// AppBar personalizado que nos permite modificar el icono
/// de regresar por default por uno propio para mayor personalizacion
// Ref: https://stackoverflow.com/questions/72076141/how-to-change-the-default-appbar-buttons-for-the-whole-app
class ExAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final String? titleText;
  final bool? centerTitle;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const ExAppBar({
    Key? key,
    this.leading,
    this.title,
    this.centerTitle,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.titleText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    Widget? leadingIcon = leading;

    if (leadingIcon == null && automaticallyImplyLeading) {
      if (hasDrawer) {
        leadingIcon = IconButton(
          icon: const Icon(Icons.menu, color: ColoresBase.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      } else {
        if (canPop) {
          // TODO: Cambiar por icono de Chevron final
          leadingIcon = IconButton(
            tooltip: 'Regresar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.chevron_left_outlined,
              color: ColoresBase.white,
            ),
          );
        }
      }
    }

    return AppBar(
        leading: Padding(
            padding: const EdgeInsets.only(top: Sizes.p3), child: leadingIcon),
        title: title ??
            Padding(
                padding: const EdgeInsets.only(top: Sizes.p3),
                child: Text(titleText ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: TextSizes.textLg,
                        fontWeight: FontWeight.w300))),
        centerTitle: centerTitle,
        backgroundColor: Colores.navegacionBackground,
        surfaceTintColor: null,
        elevation: 2,
        actions: actions,
        toolbarHeight: Sizes.p12);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
