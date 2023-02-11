import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';

Moneda calcularPrecioSinImpuestos(
  PrecioDeVentaProducto precio,
  List<Impuesto> impuestos,
) {
  var precioSinImpuestos = precio.value.toDouble();

  //impuestos puede ser final por lo que no se le puede hacer sort directamente
  var impuestosCopy = [...impuestos];

  impuestosCopy.sort((a, b) => b.ordenDeAplicacion.compareTo(
        a.ordenDeAplicacion,
      ));

  for (var impuesto in impuestosCopy) {
    var montoImpuesto = precioSinImpuestos -
        (precioSinImpuestos / (1 + (impuesto.porcentaje / 100)));

    precioSinImpuestos -= montoImpuesto;
  }

  return Moneda(precioSinImpuestos);
}
