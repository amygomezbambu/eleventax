import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_importe_con_impuestos.dart';

/// Calcula el precio sin impuestos de un producto para los [[impuestos]] y la [[paraCantidad]]
/// proporcionada re-calculando hasta que el precio sin impuestos sea igual
/// al [[precioConImpuestos]] * [[paraCantidad]].
Moneda calcularPrecioSinImpuestos(
    PrecioDeVentaProducto precioConImpuestos, List<Impuesto> impuestos,
    {double paraCantidad = 1.0}) {
  final importeEsperado =
      Moneda(precioConImpuestos.value.toDouble() * paraCantidad)
          .importeCobrable
          .toDouble();

  // TODO: Refactorizar este código para que sea más legible
  final impuestosOrdenados = ordenarImpuestosPorOrdenDeAplicacion(impuestos);

  var baseParaImpuesto = precioConImpuestos.value.toDouble();

  var sumaPorcentajes = 0.0;

  // Sumamos todos los porcentajes de impuestos que contiene el producto
  for (var impuesto in impuestosOrdenados) {
    sumaPorcentajes += impuesto.porcentaje.toPorcentajeDecimal();

    // Verificamos si tenemos el IEPS cuyo impuesto debe servir como base
    // para el IVA
    // TODO: Cambiar texto hard codeado por propiedad de entidad Impuesto
    if (impuesto.nombre == 'IEPS') {
      baseParaImpuesto = (baseParaImpuesto / (1 + sumaPorcentajes));
      sumaPorcentajes -= impuesto.porcentaje.toPorcentajeDecimal();
    }
  }

  var precioSinImpuestos = (baseParaImpuesto / (1 + sumaPorcentajes));

  // Para comenzar "forzamos" la diferencia
  var diferenciaConImporteEsperado = 0.1;
  int vecesQueHemosDevididoEntreDiez = 10;
  var iteraciones = 0;
  var ajuste = 0.01;

  // Mientras la diferencia entre el importe esperado y el calculado (precio sin impuestos + impuestos)
  // no sea cero, agregamos o quitamos centavos al precio sin impuestos hasta que
  // el resultado sea el esperado (algoritmo brute force)
  while (diferenciaConImporteEsperado != 0.000000000) {
    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(Moneda(precioSinImpuestos)),
      impuestos,
      paraCantidad: paraCantidad,
      comoImportesCobrables: true,
    ).total.importeCobrable;

    diferenciaConImporteEsperado =
        (Moneda(importeEsperado) - importeCalculado).toDouble();

    if (diferenciaConImporteEsperado != 0) {
      var numeroDecimales = 0;
      double diferenciaManipulada = diferenciaConImporteEsperado;

      // Calculamos el número de decimales que tiene la diferencia
      // para calcular el ajuste que puede acercanos más rapido al resultado
      while (diferenciaManipulada.ceil() != diferenciaManipulada.floor()) {
        diferenciaManipulada =
            diferenciaConImporteEsperado * vecesQueHemosDevididoEntreDiez;
        numeroDecimales = numeroDecimales + 1;
        vecesQueHemosDevididoEntreDiez = vecesQueHemosDevididoEntreDiez * 10;
        // Más de este número de decimales no es necesario y se excede
        // el tamaño de int generando iteraciones innecesarias es
        /// mejor reiniciar el múltiplo
        if (vecesQueHemosDevididoEntreDiez >= 100000000) {
          vecesQueHemosDevididoEntreDiez = 10;
        }
      }
      // Si la cantidad del articulo es menor a 1, restamos un decimal
      // para que al calcular el importe el ajuste no se vuelva demasiado pequeño
      // y deje de influir para las siguientes iteraciones
      if (paraCantidad < 1) {
        numeroDecimales = numeroDecimales - 1;
      }

      for (var i = 1; i < numeroDecimales; i++) {
        // Dividimos el ajuste por 10 para que sea más pequeño
        // y nuestro siguiente ajuste sea más preciso
        // (ej. 0.01, 0.001, 0.0001, etc.)
        ajuste = ajuste / 10;
      }

      // Dependiendo de si la diferencia es positiva o negativa, agregamos o
      // quitamos centavos
      if (diferenciaConImporteEsperado > 0) {
        precioSinImpuestos = precioSinImpuestos + ajuste;
      } else {
        precioSinImpuestos = precioSinImpuestos + (ajuste * -1);
      }
    }

    iteraciones++;
    if (iteraciones >= 100) {
      throw ValidationEx(
          mensaje: 'No se pudo calcular el precio sin impuestos después de '
              '$iteraciones iteraciones para precio: $precioConImpuestos y cantidad: $paraCantidad',
          tipo: TipoValidationEx.valorFueraDeRango);
    }
  }

  return Moneda(precioSinImpuestos);
}
