import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';

abstract class IRepositorioConsultaProductos {
  Future<List<Impuesto>> obtenerImpuestos();
  Future<List<Categoria>> obtenerCategorias();
  Future<List<UnidadDeMedida>> obtenerUnidadesDeMedida();
  Future<bool> existeProducto(String codigo);
}
