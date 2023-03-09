import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';

import 'package:eleventa/modulos/ventas/servicios/calcular_precio_sin_impuestos.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/porcentaje_de_impuesto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/ventas/servicios/calcular_importe_con_impuestos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'calcular precio sin impuestos con IVA y cantidad menor a 1 ...',
    () {
      final precioFinal = PrecioDeVentaProducto(Moneda(41.2431556329));
      const cantidad = 0.545;

      var impuestos = <Impuesto>[
        Impuesto.crear(
          nombre: 'IVA',
          ordenDeAplicacion: 1,
          porcentaje: PorcentajeDeImpuesto(16.0),
        ),
      ];

      final precioSinImpuestos = calcularPrecioSinImpuestos(
          precioFinal, impuestos,
          paraCantidad: cantidad);
      final importeCalculado = calcularImporteConImpuestos(
        PrecioDeVentaProducto(precioSinImpuestos),
        impuestos,
        paraCantidad: cantidad,
        comoImportesCobrables: false,
      );

      expect(importeCalculado.total.importeCobrable,
          Moneda(precioFinal.value.toDouble() * cantidad).importeCobrable,
          reason: 'No se calculo correctamente el precio sin impuestos');
    },
  );

  test(
    'calcular precio sin impuestos con IVA y la cantidad inferior minima posible (0.001) ...',
    () {
      final precioFinal = PrecioDeVentaProducto(Moneda(41.2431556329));
      const cantidad = 0.001;

      var impuestos = <Impuesto>[
        Impuesto.crear(
          nombre: 'IVA',
          ordenDeAplicacion: 1,
          porcentaje: PorcentajeDeImpuesto(16.0),
        ),
      ];

      final precioSinImpuestos = calcularPrecioSinImpuestos(
          precioFinal, impuestos,
          paraCantidad: cantidad);
      final importeCalculado = calcularImporteConImpuestos(
        PrecioDeVentaProducto(precioSinImpuestos),
        impuestos,
        paraCantidad: cantidad,
        comoImportesCobrables: false,
      );

      expect(Moneda(precioSinImpuestos.toDouble() * cantidad).montoInterno,
          importeCalculado.subtotal.montoInterno,
          reason:
              'No se calculo correctamente el precio sin impuestos, pues el subtotal no es el esperado');
    },
  );

  test(
    'calcular precio sin impuestos con IVA y cantidad menor a 1 ...',
    () {
      final precioFinal = PrecioDeVentaProducto(Moneda(24411.00));
      const cantidad = 0.545;

      var impuestos = <Impuesto>[
        Impuesto.crear(
          nombre: 'IVA',
          ordenDeAplicacion: 1,
          porcentaje: PorcentajeDeImpuesto(16.0),
        ),
      ];

      final precioSinImpuestos = calcularPrecioSinImpuestos(
          precioFinal, impuestos,
          paraCantidad: cantidad);
      final importeCalculado = calcularImporteConImpuestos(
        PrecioDeVentaProducto(precioSinImpuestos),
        impuestos,
        paraCantidad: cantidad,
        comoImportesCobrables: false,
      );

      expect(importeCalculado.total.importeCobrable,
          Moneda(precioFinal.value.toDouble() * cantidad).importeCobrable,
          reason: 'No se calculo correctamente el precio sin impuestos');
    },
  );

  test('calcular precio sin impuesto con IVA y IEPS ...', () {
    var precioFinal = PrecioDeVentaProducto(Moneda(24411.00));
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

    final precioSinImpuestos =
        calcularPrecioSinImpuestos(precioFinal, impuestos);
    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(importeCalculado.total, precioFinal.value.importeCobrable);
  });

  test('calcular precio sin impuesto de producto 3 ...', () {
    var precioFinal = PrecioDeVentaProducto(Moneda(500.00));
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
      Impuesto.crear(
        nombre: 'ISH',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(12.0),
      )
    ];

    final precioSinImpuestos =
        calcularPrecioSinImpuestos(precioFinal, impuestos);
    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(importeCalculado.total.montoInterno, precioFinal.value.montoInterno);
  });

  test('calcular precio sin impuesto de producto 4 ...', () {
    var precioFinal = PrecioDeVentaProducto(Moneda(500.00));
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
      Impuesto.crear(
        nombre: 'ISH',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(3.0),
      )
    ];

    const cantidad = 7.0;
    final precioSinImpuestos = calcularPrecioSinImpuestos(
        precioFinal, impuestos,
        paraCantidad: cantidad);
    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: cantidad,
      comoImportesCobrables: true,
    );

    expect(importeCalculado.total.montoInterno,
        precioFinal.value.montoInterno * cantidad);
  });

  test('calcular importe', () {
    var precioSinImpuestos = PrecioDeVentaProducto(Moneda(420.165100));
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
      Impuesto.crear(
        nombre: 'ISH',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(3.0),
      )
    ];

    var resultado = calcularImporteConImpuestos(
      precioSinImpuestos,
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(resultado.total.montoInterno, 500000000);
  });

  test('calcular precio sin impuesto de producto ...', () {
    var precioFinal = PrecioDeVentaProducto(Moneda(500.00));
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
      Impuesto.crear(
        nombre: 'ISH',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(3.0),
      )
    ];

    final precioSinImpuestos =
        calcularPrecioSinImpuestos(precioFinal, impuestos);
    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(importeCalculado.total.montoInterno, precioFinal.value.montoInterno);
  });

  test('calcular precio sin impuesto de producto 2 ...', () {
    var precioFinal = PrecioDeVentaProducto(Moneda(500.00));
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
      Impuesto.crear(
        nombre: 'ISH',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(8.0),
      )
    ];

    final precioSinImpuestos =
        calcularPrecioSinImpuestos(precioFinal, impuestos);
    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(importeCalculado.total.montoInterno, precioFinal.value.montoInterno);
  });

  test(
      'calcular precio sin impuesto de producto con IVA y 6 decimales objetivo ...',
      () {
    var precioFinal = PrecioDeVentaProducto(Moneda(35.554445));
    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
    ];

    final precioSinImpuestos =
        calcularPrecioSinImpuestos(precioFinal, impuestos);

    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: 1.0,
      comoImportesCobrables: true,
    );

    expect(importeCalculado.total, precioFinal.value.importeCobrable);
  });

  test('calcular precio sin impuesto de producto con IVA, escenario A ...', () {
    final precioFinal = PrecioDeVentaProducto(Moneda(41.2431556329));
    const cantidad = 2.0;

    var impuestos = <Impuesto>[
      Impuesto.crear(
        nombre: 'IVA',
        ordenDeAplicacion: 1,
        porcentaje: PorcentajeDeImpuesto(16.0),
      ),
    ];

    final precioSinImpuestos = calcularPrecioSinImpuestos(
      precioFinal,
      impuestos,
      paraCantidad: cantidad,
    );

    final importeCalculado = calcularImporteConImpuestos(
      PrecioDeVentaProducto(precioSinImpuestos),
      impuestos,
      paraCantidad: cantidad,
      comoImportesCobrables: false,
    );
    final totalEsperado = precioFinal.value.toDouble() * cantidad;

    expect(importeCalculado.total.montoInterno,
        Moneda(totalEsperado).montoInterno);
  });
}
