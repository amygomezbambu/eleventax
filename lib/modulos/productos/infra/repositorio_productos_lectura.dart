import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/infra/repositorio_lectura.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos_lectura.dart';

class RepositorioLecturaProductos extends RepositorioLectura
    implements IRepositorioLecturaProductos {
  RepositorioLecturaProductos({
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
  Future<List<String>> obtenerCategorias() async {
    return <String>['Refrescos', 'Carnes', 'Papeleria', 'Enlatados'];
  }
}
