import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_categoria.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../loader_for_tests.dart';

void main() {
  setUpAll(() async {
    TestsLoader loader = TestsLoader();
    await loader.iniciar();
  });

  test('eliminar categoria ...', () async {
    Dependencias.infra.database().verbose = true;

    final consultas = ModuloProductos.repositorioConsultaProductos();
    final crearCategoria = ModuloProductos.crearCategoria();
    final eliminarCategoria = ModuloProductos.eliminarCategoria();

    final nombreCategoria = NombreCategoria('lacteos');
    var categoria = Categoria.crear(nombre: nombreCategoria);
    crearCategoria.req.categoria = categoria;
    await crearCategoria.exec();

    eliminarCategoria.req.uidCategoria = categoria.uid;
    await eliminarCategoria.exec();

    var categoriaDB = await consultas.obtenerCategoria(categoria.uid);

    expect(categoriaDB!.eliminado, true, reason: 'No se eliminó la categoria');
  });
}
