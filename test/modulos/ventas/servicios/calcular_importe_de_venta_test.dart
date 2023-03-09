import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';

import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_importe_con_impuestos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calcular importe correcto con IVA y IEPS ...', () {
    var precioSinImpuestos = Moneda(19485.155);
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IEPS',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(8.0),
      ),
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 2,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
    ];

    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(Moneda(24411.00), importeCalculado.total);
  });

  test('calcular importes correctos ...', () {
    final precioSinImpuestos = Moneda(36.637931);
    const cantidad = 2.45677;

    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 2,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
    ];

    final importesCalculados = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: cantidad,
      comoImportesCobrables: true,
    );

    expect(importesCalculados.subtotal.montoInterno, Moneda(90.01).montoInterno,
        reason: 'El subtotal no fue el esperado');
    expect(importesCalculados.totalImpuestos, Moneda(14.4000000),
        reason: 'El total de impuestos no fue el esperado');
    expect(importesCalculados.total, Moneda(104.410000),
        reason: 'El total no fue el esperado');
  });
}
