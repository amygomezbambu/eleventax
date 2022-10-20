import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:meta/meta.dart';

class RepositorioConsulta {
  @protected
  late IAdaptadorDeBaseDeDatos db;

  RepositorioConsulta(this.db);
}
