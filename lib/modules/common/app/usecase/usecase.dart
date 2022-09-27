import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/common/domain/entity.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:meta/meta.dart';

///Clase base para todos los casos de uso
///
///Todos los casos de uso deben extender esta clase
///[T] es el tipo de dato que devuelve el caso de uso al ejecuta exec()
class Usecase<T> {
  @protected
  final IRepository<Entity>? repo;
  @protected
  late ILogger logger;
  @protected
  late final Future<T> Function() operation;

  Usecase([this.repo, ILogger? logger]) {
    this.logger = (logger != null) ? logger : Dependencies.infra.logger();
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
    if (ex is DomainException) {
      logger.info(ex.message);
    } else if (ex is InfrastructureException) {
      logger.error(ex: ex);
    } else {
      logger.error(ex: ex, stackTrace: stack);
    }
  }
}
