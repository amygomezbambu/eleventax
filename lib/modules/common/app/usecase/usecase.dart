import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/repository.dart';
import 'package:eleventa/modules/common/error/error.dart';
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
      //Operacion Real
      result = await operation();
      await repo.commit();
    } catch (e, stackTrace) {
      await repo.rollback();
      logger.error(EleventaError((e as Exception).toString(), stackTrace));
      rethrow;
    }

    return result;
  }
}
