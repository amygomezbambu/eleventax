import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/domain/total_de_impuesto.dart';

class ImportesDeArticulo {
  final Moneda subtotal;
  final Moneda total;
  final Moneda totalImpuestos;
  final List<TotalDeImpuesto> totalesDeImpuestos;

  ImportesDeArticulo(
      {required this.subtotal,
      required this.total,
      required this.totalImpuestos,
      required this.totalesDeImpuestos});
}

List<Impuesto> ordenarImpuestosPorOrdenDeAplicacion(List<Impuesto> impuestos) {
  var res = [...impuestos];
  res.sort((b, a) => b.ordenDeAplicacion.compareTo(
        a.ordenDeAplicacion,
      ));
  return res;
}

/// Calcula el importe final en base a [[precioSinImpuestos]] e [[impuestos]]
/// y [[paraCantidad]]. Si el parámetro [[comoImportesCobrables]] es verdadero,
/// se retornan los importes a 2 decimales (ejem: en una venta)
ImportesDeArticulo calcularImporteConImpuestos(
    PrecioDeVentaProducto precioSinImpuestos, List<Impuesto> impuestos,
    {required double paraCantidad, required bool comoImportesCobrables}) {
  List<TotalDeImpuesto> totalesDeImpuestos = [];
  // Calculamos el subtotal del articulo en base al precio sin impuestos calculado
  var subtotalCalculado =
      Moneda(precioSinImpuestos.value.toDouble() * paraCantidad);
  var baseDelImpuesto = subtotalCalculado;

  final impuestosOrdenados = ordenarImpuestosPorOrdenDeAplicacion(impuestos);

  totalesDeImpuestos.clear();

  for (var impuesto in impuestosOrdenados) {
    final montoDeImpuesto =
        baseDelImpuesto.toDouble() * impuesto.porcentaje.toPorcentajeDecimal();

    TotalDeImpuesto totalDeImpuesto = TotalDeImpuesto(
        base: baseDelImpuesto,
        monto: Moneda(montoDeImpuesto),
        impuesto: impuesto);

    totalesDeImpuestos.add(totalDeImpuesto);

    // Verificamos si tenemos que calcular el IEPS
    // TODO: Cambiar texto hard codeado por propiedad de entidad Impuesto
    if (impuesto.nombre == 'IEPS') {
      // Si el impuesto es IEPS debe servir como base para el IVA
      baseDelImpuesto = baseDelImpuesto + Moneda(montoDeImpuesto);
    }
  }

  Moneda montoImpuestos;
  Moneda total;
  if (comoImportesCobrables) {
    subtotalCalculado = subtotalCalculado.importeCobrable;
    montoImpuestos = totalesDeImpuestos.fold(
        Moneda(0),
        (previousValue, element) =>
            previousValue.importeCobrable + element.monto.importeCobrable);

    total = subtotalCalculado + montoImpuestos.importeCobrable;
  } else {
    montoImpuestos = totalesDeImpuestos.fold(
      Moneda(0),
      (previousValue, element) => previousValue + element.monto,
    );
    total = subtotalCalculado + montoImpuestos;
  }

  return ImportesDeArticulo(
    subtotal: subtotalCalculado,
    total: total,
    totalImpuestos: montoImpuestos,
    totalesDeImpuestos: totalesDeImpuestos,
  );
}
