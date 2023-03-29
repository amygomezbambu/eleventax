import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:eleventa/modulos/common/ui/tema/dimensiones.dart';
import 'package:flutter/material.dart';

class ExBoton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double tamanoFuente;
  final double height;
  final double width;
  final Color colorBoton;
  final Color colorIcono;
  final Color colorTexto;
  final Color? colorBorde;

  const ExBoton.primario({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tamanoFuente = TextSizes.textSm,
    this.height = Sizes.p12,
    this.width = double.maxFinite,
    this.colorBoton = Colores.accionPrimaria,
    this.colorIcono = ColoresBase.primario400,
    this.colorTexto = ColoresBase.white,
    this.colorBorde,
    Key? key,
  }) : super(key: key);

  const ExBoton.secundario({
    required this.label,
    required this.icon,
    required this.onTap,
    this.tamanoFuente = TextSizes.textSm,
    this.height = Sizes.p12,
    this.width = Sizes.infinito,
    this.colorBoton = ColoresBase.white,
    this.colorIcono = ColoresBase.neutral500,
    this.colorTexto = ColoresBase.neutral600,
    this.colorBorde = ColoresBase.neutral300,
    Key? key,
  }) : super(key: key);

  @override
  State<ExBoton> createState() => _ExBotonState();
}

class _ExBotonState extends State<ExBoton> {
  bool loading = false;

  void _onTap() {
    // setState(() {
    //   loading = true;
    // });

    // // Pasando unos segundos restauramos el estado del botón
    // Future.delayed(const Duration(seconds: 1), () {
    //   if (!mounted) return;
    //   setState(() {
    //     loading = false;
    //   });
    // });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          //surfaceTintColor: Colors.transparent,

          side: widget.colorBorde != null
              ? BorderSide(
                  width: Sizes.px,
                  color: widget.colorBorde!,
                )
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.p2),
          ),
          backgroundColor: widget.colorBoton,
          foregroundColor: widget.colorBoton,
          disabledBackgroundColor: ColoresBase.primario300,
          elevation: 1.5,
          shadowColor: ColoresBase.shadow100,
          minimumSize: Size(widget.width, widget.height),
        ),

        // Si ya se hizo clic, des-asignamos el evento onPressed
        // para evitar doble clics y por tanto repetir una acción
        onPressed: _onTap,
        //onPressed: loading ? null : _onTap,
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
                  : Icon(widget.icon, color: widget.colorIcono, size: Sizes.p4),
            ),
            Padding(
              padding: const EdgeInsets.only(left: Sizes.p1),
              child: Text(widget.label,
                  style: TextStyle(
                    color: widget.colorTexto,
                    fontSize: widget.tamanoFuente,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -Sizes.p0_5,
                  )),
            ),
          ],
        ));
  }
}
