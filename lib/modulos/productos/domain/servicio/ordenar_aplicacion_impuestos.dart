import 'package:eleventa/modulos/productos/domain/impuesto.dart';

List<Impuesto> ordenarImpuestosPorOrdenDeAplicacion(List<Impuesto> impuestos) {
  var impuestosCopy = [...impuestos];
  impuestosCopy.sort((b, a) => b.ordenDeAplicacion.compareTo(
        a.ordenDeAplicacion,
      ));
  return impuestosCopy;
}
