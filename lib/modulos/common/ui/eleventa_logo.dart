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
      width: 30.0,
      height: 30.0,
      color: const Color(0xFF459BF1),
    );
  }
}
