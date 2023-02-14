import 'package:eleventa/modulos/common/exception/excepciones.dart';

enum TiposVentasEx {
  errorDeValidacion,
  productoNoExiste,
  pagosInsuficientes,
  ventaYaCobrada,
}

class VentasEx extends AppEx {
  @override
  TiposVentasEx get tipo => tipo_ as TiposVentasEx;
  VentasEx({
    required TiposVentasEx tipo,
    required super.message,
    super.input,
  }) : super(tipo: tipo);
}
