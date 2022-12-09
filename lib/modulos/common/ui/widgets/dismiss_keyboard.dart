import 'dart:io';

import 'package:flutter/material.dart';

/// Widget que oculta el teclado virtual al tocar cualquier parte de la pantalla
/// para seguir la convención de iOS/Android, en sistemas operativos Desktop no hace nada
// Tomado de: https://www.kindacode.com/article/flutter-dismiss-keyboard-when-tap-outside-text-field/
class DismissKeyboard extends StatelessWidget {
  final Widget child;
  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS || Platform.isAndroid)
        ? GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: child)
        // En desktop no hacemos nada especial, regresamos el Widget hijo
        : child;
  }
}
