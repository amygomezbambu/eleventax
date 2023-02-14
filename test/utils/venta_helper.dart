import 'package:eleventa/modulos/productos/domain/impuesto.dart';

class DatosProducto {
  double cantidad;
  double precioDeVenta;
  List<Impuesto> impuestos;

  DatosProducto({
    required this.cantidad,
    required this.precioDeVenta,
    required this.impuestos,
  });
}

class DatosVenta {
  List<DatosProducto> productos;

  DatosVenta({required this.productos});
}

final iva16 =
    Impuesto.crear(nombre: 'IVA', porcentaje: 16.0, ordenDeAplicacion: 2);

final iva8 =
    Impuesto.crear(nombre: 'IVA8', porcentaje: 8.0, ordenDeAplicacion: 2);

final ieps8 =
    Impuesto.crear(nombre: 'IEPS', porcentaje: 8.0, ordenDeAplicacion: 1);

final ventas = [
  DatosVenta(
    productos: [
      DatosProducto(
        cantidad: 2.00,
        precioDeVenta: 41.2431556329,
        impuestos: <Impuesto>[iva16],
      ),
    ],
  ),
  DatosVenta(
    productos: [
      DatosProducto(
        cantidad: 1.00,
        precioDeVenta: 24411.00,
        impuestos: <Impuesto>[iva16, ieps8],
      ),
    ],
  ),
  DatosVenta(
    productos: [
      DatosProducto(
        cantidad: 1.00,
        precioDeVenta: 545.00,
        impuestos: <Impuesto>[iva8],
      ),
      DatosProducto(
        cantidad: 3.00,
        precioDeVenta: 295.00,
        impuestos: <Impuesto>[iva8],
      ),
      DatosProducto(
        cantidad: 1.00,
        precioDeVenta: 495.00,
        impuestos: <Impuesto>[iva8],
      ),
    ],
  ),
  DatosVenta(
    productos: [
      DatosProducto(
        cantidad: 1.00,
        precioDeVenta: 554.960356,
        impuestos: <Impuesto>[iva16],
      ),
      DatosProducto(
        cantidad: 3.00,
        precioDeVenta: 300.391396,
        impuestos: <Impuesto>[iva16],
      ),
      DatosProducto(
        cantidad: 1.00,
        precioDeVenta: 504.046564,
        impuestos: <Impuesto>[iva8],
      ),
    ],
  )
];



// Venta crearVentaDePrueba(String cadenaArticulos, {required double tasaIVA}) {
  //   final impuestos = <Impuesto>[
  //     Impuesto.crear(nombre: 'IVA', porcentaje: tasaIVA, ordenDeAplicacion: 2),
  //   ];

  //   var venta = Venta.crear();

  //   // Separamos los articulos por el pipe
  //   var articulos = cadenaArticulos.split('|');
  //   for (var i = 0; i < articulos.length; i++) {
  //     var articulo = articulos[i];
  //     var datosArticulo = articulo.split('*');
  //     var cantidad = datosArticulo[0];
  //     var precio = datosArticulo[1];

  //     final precioConImpuestos = Moneda(precio);

  //     var producto = ProductosUtils.crearProducto(
  //       impuestos: impuestos,
  //       precioCompra: precioConImpuestos,
  //       precioVenta: precioConImpuestos,
  //     );

  //     var articuloDeVenta =
  //         Articulo.crear(producto: producto, cantidad: double.parse(cantidad));
  //     venta.agregarArticulo(articuloDeVenta);
  //   }

  //   return venta;
  // }
