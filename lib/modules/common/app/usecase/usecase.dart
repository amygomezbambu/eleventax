import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:meta/meta.dart';

class Usecase<T> {
  @protected
  final IRepository repo;
  @protected
  late final ILogger logger;

  @protected
  late final Future<T> Function() operation;

  Usecase(this.repo) {
    logger = Dependencies.infra.logger();
  }

  Future<T> exec() async {
    logger.info('Ejecutando caso de uso ${runtimeType.toString()}');

    late T result;

    await repo.transaction();

    try {
      result = await operation();

      await repo.commit();
    } catch (ex, stackTrace) {
      await repo.rollback();

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
      logger.error(ex: ex as Exception, stackTrace: stack);
    }
  }
}
