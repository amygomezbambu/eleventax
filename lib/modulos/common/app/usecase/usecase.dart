import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/repositorio.dart';
import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:meta/meta.dart';

///Clase base para todos los casos de uso
///
///Todos los casos de uso deben extender esta clase
///[T] es el tipo de dato que devuelve el caso de uso al ejecuta exec()
class Usecase<T> {
  @protected
  final IRepositorio<Entidad>? repo;
  @protected
  late ILogger logger;
  @protected
  late final Future<T> Function() operation;

  Usecase([this.repo, ILogger? logger]) {
    this.logger = (logger != null) ? logger : Dependencias.infra.logger();
  }

  Future<T> exec() async {
    logger.info('Ejecutando caso de uso ${runtimeType.toString()}');

    late T result;

    await repo?.transaction();

    try {
      result = await operation();

      await repo?.commit();
    } catch (ex, stackTrace) {
      await repo?.rollback();

      logException(ex, stackTrace);

      rethrow;
    }

    return result;
  }

  void logException(Object ex, StackTrace stack) {
    if (ex is DomainEx) {
      logger.info(ex.message);
    } else if (ex is InfraEx) {
      logger.error(ex: ex);
    } else {
      logger.error(ex: ex, stackTrace: stack);
    }
  }
}
