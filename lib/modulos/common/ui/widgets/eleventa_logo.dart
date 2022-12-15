import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EleventaLogo extends StatelessWidget {
  const EleventaLogo({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/eleventa.svg',
      width: Sizes.p8,
      height: Sizes.p8,
      color: ColoresBase.primario500, //const Color(0xFF459BF1),
    );
  }
}
