import 'package:flutter/material.dart';

class BotonPrimario extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double tamanoFuente;

  const BotonPrimario({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tamanoFuente = 22.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color(0xFF3973CE),
            elevation: 4
            //minimumSize: Size(350, 70)
            ),
        onPressed: onTap,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: const Color.fromARGB(255, 137, 196, 251), size: 30),
            Text(label,
                style: TextStyle(
                  //fontFamily: 'Figtree',
                  color: Colors.white,
                  fontSize: tamanoFuente,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1.1,
                )),
          ],
        ));
  }
}
