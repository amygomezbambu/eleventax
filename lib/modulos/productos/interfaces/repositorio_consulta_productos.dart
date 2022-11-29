import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';

abstract class IRepositorioConsultaProductos {
  Future<List<Impuesto>> obtenerImpuestos();
  Future<List<Categoria>> obtenerCategorias();
  Future<Categoria?> obtenerCategoria(UID uid);
  Future<List<UnidadDeMedida>> obtenerUnidadesDeMedida();
  Future<bool> existeProducto(String codigo);
  Future<List<Producto>> obtenerProductos();
  Future<Producto?> obtenerProducto(UID uid);
  Future<Producto?> obtenerProductoPorCodigo(CodigoProducto codigo);
  Future<List<Impuesto>> obtenerImpuestosParaProducto(UID productoUID);
  Future<UID> obtenerRelacionProductoImpuesto(
    UID productoUID,
    UID impuestoUID,
  );
  Future<bool> existeCategoria({required String nombre});
  Future<bool> existe(UID uid);
}
