import 'dart:io';

import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/infra/repositorio.dart';

class TestDatabaseUtils extends Repositorio {
  TestDatabaseUtils()
      : super(Dependencias.infra.sync(), Dependencias.infra.database());

  Future<void> limpar({required String tabla}) async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      throw Exception('No debes limpiar la base de datos en producción');
    }

    await db.command(sql: 'DELETE FROM $tabla');
  }
}
