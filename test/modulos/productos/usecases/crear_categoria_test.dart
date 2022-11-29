import 'package:eleventa/modulos/common/exception/excepciones.dart';
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

  test('debe crear la categoria si los datos son correctos', () async {
    //Dependencias.infra.logger().activarLogeoParaPruebas(true);

    final consultas = ModuloProductos.repositorioConsultaProductos();
    final crearCategoria = ModuloProductos.crearCategoria();
    final nombreCategoria = NombreCategoria('Abarrotes');
    var categoria = Categoria.crear(nombre: nombreCategoria);

    crearCategoria.req.categoria = categoria;

    await crearCategoria.exec();

    var categoriaDB = await consultas.obtenerCategoria(categoria.uid);

    expect(categoriaDB, isNotNull);
    expect(categoriaDB!.nombre, nombreCategoria.value);
  });

  test(
      'debe lanzar excepción si se proporciona el nombre Sin Categoria o silimares',
      () async {
    var valorInvalido1 = 'Sin Categoría';
    var valorInvalido2 = 'SinCategoría';
    var valorInvalido3 = 'Sin   Categoría ';
    var valorInvalido4 = 'Sin Categoria ';
    var valorInvalido5 = 'SIN CATEGORIA';
    var valorInvalido6 = 'SinCategoria';

    expect(() => NombreCategoria(valorInvalido1), throwsA(isA<DomainEx>()));
    expect(() => NombreCategoria(valorInvalido2), throwsA(isA<DomainEx>()));
    expect(() => NombreCategoria(valorInvalido3), throwsA(isA<DomainEx>()));
    expect(() => NombreCategoria(valorInvalido4), throwsA(isA<DomainEx>()));
    expect(() => NombreCategoria(valorInvalido5), throwsA(isA<DomainEx>()));
    expect(() => NombreCategoria(valorInvalido6), throwsA(isA<DomainEx>()));
  });

  test(
      'debe permitir crear categoria si existe otra con el mismo nombre pero borrada',
      () async {
    var eliminarCategoria = ModuloProductos.eliminarCategoria();
    var crearCategoria = ModuloProductos.crearCategoria();
    var consultas = ModuloProductos.repositorioConsultaProductos();

    var nombreCategoria = NombreCategoria('Carnes frías');
    var categoria = Categoria.crear(nombre: nombreCategoria);
    crearCategoria.req.categoria = categoria;
    await crearCategoria.exec();

    eliminarCategoria.req.uidCategoria = categoria.uid;
    await eliminarCategoria.exec();

    categoria = Categoria.crear(nombre: nombreCategoria);
    crearCategoria.req.categoria = categoria;
    await crearCategoria.exec();

    var categoriaDB = await consultas.obtenerCategoria(categoria.uid);

    expect(categoriaDB!.nombre, categoria.nombre);
  });

  test('debe lanzar excepcion si ya existe una categoria con el mismo nombre',
      () async {
    //Dependencias.infra.logger().activarLogeoParaPruebas(true);

    const nombreCategoriaARepetir = 'Categoria a repetir';
    var crearCategoria = ModuloProductos.crearCategoria();
    crearCategoria.req.categoria =
        Categoria.crear(nombre: NombreCategoria(nombreCategoriaARepetir));
    await crearCategoria.exec();

    crearCategoria.req.categoria =
        Categoria.crear(nombre: NombreCategoria(nombreCategoriaARepetir));
    await expectLater(crearCategoria.exec(), throwsA(isA<AppEx>()));
  });
}
