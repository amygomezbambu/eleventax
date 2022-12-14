import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:meta/meta.dart';

class RepositorioConsulta {
  final IAdaptadorDeBaseDeDatos _db;
  @protected
  ILogger logger;

  RepositorioConsulta(this._db, this.logger);

  @protected
  Future<QueryResult> query({
    required String sql,
    QueryParams params,
  }) async {
    try {
      return await _db.query(sql: sql, params: params);
    } catch (e) {
      logger.error(ex: e);
      rethrow;
    }
  }
}
