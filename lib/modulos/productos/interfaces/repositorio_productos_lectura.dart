import 'package:eleventa/modulos/productos/domain/impuesto.dart';

abstract class IRepositorioLecturaProductos {
  Future<List<Impuesto>> obtenerImpuestos();

  Future<List<String>> obtenerCategorias();
}
