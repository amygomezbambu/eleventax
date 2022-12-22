import 'package:eleventa/modulos/common/ui/tema/colores.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_boton_primario.dart';

class ExBotonSecundario extends ExBotonPrimario {
  const ExBotonSecundario(
      {super.key, required label, required icon, required onTap})
      : super(
            colorBoton: ColoresBase.neutral200,
            colorIcono: ColoresBase.neutral500,
            colorTexto: ColoresBase.neutral500,
            label: label,
            icon: icon,
            onTap: onTap);
}
