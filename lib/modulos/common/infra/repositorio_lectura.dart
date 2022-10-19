import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:meta/meta.dart';

class RepositorioLectura {
  @protected
  late IAdaptadorDeBaseDeDatos db;

  RepositorioLectura(this.db);
}
