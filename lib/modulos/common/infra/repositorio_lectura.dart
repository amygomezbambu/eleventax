import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:meta/meta.dart';

class RepositorioConsultas {
  @protected
  late IAdaptadorDeBaseDeDatos db;

  RepositorioConsultas(this.db);
}
