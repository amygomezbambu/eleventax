import 'package:flutter/material.dart';

import 'package:eleventa/modulos/common/ui/design_system.dart';

/// AppBar personalizado que nos permite modificar el icono
/// de regresar por default por uno propio para mayor personalizacion
// Ref: https://stackoverflow.com/questions/72076141/how-to-change-the-default-appbar-buttons-for-the-whole-app
class ExAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// This part is copied from AppBar class
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    Widget? leadingIcon = leading;

    if (leadingIcon == null && automaticallyImplyLeading) {
      if (hasDrawer) {
        leadingIcon = IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        );
      } else {
        if (canPop) {
          leadingIcon = IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.chevron_left_outlined,
              color: Colors.white,
            ),
          );
        }
      }
    }

    return AppBar(
        leading: leadingIcon,
        title: title,
        centerTitle: centerTitle,
        backgroundColor: DesignSystem.titleColor,
        surfaceTintColor: null,
        elevation: 0,
        actions: actions,
        toolbarHeight: 55);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
