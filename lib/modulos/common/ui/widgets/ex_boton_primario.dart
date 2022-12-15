import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:eleventa/modulos/common/ui/tema/dimensiones.dart';
import 'package:flutter/material.dart';

class ExBotonPrimario extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double tamanoFuente;
  final double height;

  const ExBotonPrimario({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tamanoFuente = TextSizes.textSm,
    this.height = Sizes.p10,
    Key? key,
  }) : super(key: key);

  @override
  State<ExBotonPrimario> createState() => _ExBotonPrimarioState();
}

class _ExBotonPrimarioState extends State<ExBotonPrimario> {
  bool loading = false;

  void _onTap() {
    setState(() {
      loading = true;
    });

    // Pasando unos segundos restauramos el estado del botón
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.p2),
              ),
              backgroundColor: Colores.accionPrimaria,
              foregroundColor: ColoresBase.primario700,
              disabledBackgroundColor: ColoresBase.primario300,
              elevation: 1
              //minimumSize: Size(350, 70)
              ),
          // Si ya se hizo clic, des-asignamos el evento onPressed
          // para evitar doble clics y por tanto repetir una acción
          onPressed: loading ? null : _onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: Sizes.p2),
                child: loading
                    ? Transform.scale(
                        scale: Sizes.p0_5,
                        child: const CircularProgressIndicator(
                          color: ColoresBase.primario300,
                        ))
                    : Icon(widget.icon,
                        color: ColoresBase.primario400, size: Sizes.p4),
              ),
              Padding(
                padding: const EdgeInsets.only(left: Sizes.p1),
                child: Text(widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.tamanoFuente,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -Sizes.p0_5,
                    )),
              ),
            ],
          )),
    );
  }
}
