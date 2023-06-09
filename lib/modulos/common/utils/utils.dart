import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/utils/db_utils.dart';
import 'package:eleventa/modulos/common/utils/string.dart';

class Utils {
  static DBUtils db = DBUtils();
  static IRed red = Dependencias.infra.red();
  static StringUtils string = StringUtils();
}
