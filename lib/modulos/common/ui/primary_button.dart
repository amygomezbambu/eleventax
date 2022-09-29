import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String _label;
  final IconData _icon;
  final VoidCallback onTap;

  const PrimaryButton(
    this._label,
    this._icon,
    this.onTap, {
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
            Icon(_icon,
                color: const Color.fromARGB(255, 137, 196, 251), size: 30),
            Text(_label,
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -1.1,
                )),
          ],
        ));
  }
}
