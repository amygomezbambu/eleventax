import 'package:flutter/material.dart';

class ExBotonPrimario extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double tamanoFuente;
  final double height;

  const ExBotonPrimario({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tamanoFuente = 15.0,
    this.height = 40,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: const Color(0xFF3973CE),
              elevation: 1
              //minimumSize: Size(350, 70)
              ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: const Color.fromARGB(255, 137, 196, 251), size: 18),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: tamanoFuente,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                    )),
              ),
            ],
          )),
    );
  }
}
