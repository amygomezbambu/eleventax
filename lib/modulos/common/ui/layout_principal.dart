//import 'package:eleventa/modules/common/ui/ui_consts.dart' as ui;
import 'package:flutter/material.dart';

class LayoutPrincipal extends StatefulWidget {
  final Widget child;

  const LayoutPrincipal({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  LayoutPrincipalState createState() => LayoutPrincipalState();
}

class LayoutPrincipalState extends State<LayoutPrincipal> {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: widget.child);
  }
}
