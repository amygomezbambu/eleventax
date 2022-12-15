import 'dart:convert';

import 'package:eleventa/modulos/common/infra/repositorio.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/telemetria/entidad/evento_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';

class RepositorioTelemetria extends Repositorio
    implements IRepositorioTelemetria {
  RepositorioTelemetria(super.adaptadorSync, super.db);

  @override
  Future<void> agregarAQueue(EventoTelemetria evento) async {
    const sql =
        '''INSERT into metricas_queue(uid, ip, evento, esPerfil, propiedades)
      VALUES(?, ?, ?, ?, ?);''';

    await db.command(sql: sql, params: [
      evento.uid.toString(),
      evento.ip,
      evento.tipo != null ? evento.tipo!.index : null,
      Utils.db.boolToInt(evento.esPerfil),
      json.encode(evento.propiedades),
    ]);
  }

  @override
  Future<void> eliminarDeQueue(UID uid) async {
    const sql = '''DELETE FROM metricas_queue WHERE uid = ?; ''';

    await db.command(sql: sql, params: [uid.toString()]);
  }
}
