import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:flutter/material.dart';

class ExBotonSecundario extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double tamanoFuente;
  final double height;

  const ExBotonSecundario({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tamanoFuente = 15.0,
    this.height = 40,
    Key? key,
  }) : super(key: key);

  @override
  State<ExBotonSecundario> createState() => _ExBotonSecundarioState();
}

class _ExBotonSecundarioState extends State<ExBotonSecundario> {
  bool loading = false;

  void _onTap() {
    setState(() {
      loading = true;
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                  offset: Offset(0, 2),
                  color: Color(0x1018280D),
                  blurRadius: 2.0,
                  spreadRadius: 0)
            ]),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              side: const BorderSide(
                width: 1.0,
                color: ColoresBase.neutral300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: ColoresBase.neutral200,
              foregroundColor: ColoresBase.neutral100,
              disabledBackgroundColor: ColoresBase.neutral100,
              elevation: 0,
            ),
            // Si ya se hizo clic, des-asignamos el evento onPressed
            // para evitar doble clics y por tanto repetir una acción
            onPressed: loading ? null : _onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: loading
                      ? Transform.scale(
                          scale: 0.5,
                          child: const CircularProgressIndicator(
                            color: ColoresBase.neutral400,
                          ))
                      : Icon(widget.icon,
                          color: ColoresBase.neutral500,
                          size: widget.tamanoFuente + 3),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(widget.label,
                      style: TextStyle(
                        color: ColoresBase.neutral500,
                        fontSize: widget.tamanoFuente,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                      )),
                ),
              ],
            )),
      ),
    );
  }
}
