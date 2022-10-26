import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/infra/repositorio_consulta.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';

class RepositorioConsultaProductos extends RepositorioConsulta
    implements IRepositorioConsultaProductos {
  RepositorioConsultaProductos({
    required IAdaptadorDeBaseDeDatos db,
  }) : super(db);

  @override
  Future<List<Impuesto>> obtenerImpuestos() async {
    List<Impuesto> res = [];
    var dbResult =
        await db.query(sql: 'SELECT uid, nombre, porcentaje FROM impuestos;');

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        res.add(Impuesto(
            uid: UID(row['uid'] as String),
            nombre: row['nombre'] as String,
            porcentaje: (row['porcentaje'] as int).toDouble()));
      }
    }

    return res;
  }

  @override
  Future<List<Categoria>> obtenerCategorias() async {
    List<Categoria> categorias = [];
    var dbResult =
        await db.query(sql: 'SELECT uid, nombre FROM productos_categorias;');

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        categorias.add(Categoria(
            uid: UID(row['uid'] as String), nombre: row['nombre'] as String));
      }
    }

    return categorias;
  }

  @override
  Future<List<UnidadDeMedida>> obtenerUnidadesDeMedida() async {
    List<UnidadDeMedida> res = [];
    var dbResult = await db.query(
        sql: 'SELECT uid, nombre, abreviacion FROM unidades_medida;');

    if (dbResult.isNotEmpty) {
      for (var row in dbResult) {
        res.add(UnidadDeMedida(
            uid: UID(row['uid'] as String),
            nombre: row['nombre'] as String,
            abreviacion: row['abreviacion'] as String));
      }
    }

    return res;
  }

  @override
  Future<bool> existeProducto(String codigo) async {
    var dbResult = await db.query(
      sql: 'SELECT codigo FROM productos where codigo = ? and borrado = ?;',
      params: [codigo, false],
    );

    return dbResult.isNotEmpty;
  }
}
