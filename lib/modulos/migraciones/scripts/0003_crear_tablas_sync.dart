// ignore_for_file: file_names

import 'package:eleventa/modulos/migraciones/migracion.dart';

class Migracion3 extends Migracion {
  Migracion3() : super() {
    version = 3;
  }

  @override
  Future<void> operacion() async {
    var command = 'create table crdt('
        'hlc varchar(40),'
        'dataset varchar(100),'
        'rowId varchar(50),'
        'column varchar(50),'
        'value text,'
        'type char,' //S: string, N: number, B: Bool
        'isLocal integer,'
        'sended integer,'
        'applied integer,'
        'version integer'
        ');';

    await db.command(sql: command);

    command = 'create table syncConfig(hlc varchar(40), merkle text);';

    await db.command(sql: command);

    command = 'insert into syncConfig(hlc,merkle) values(?,?);';

    await db.command(sql: command, params: ['', '']);
  }

  @override
  Future<bool> validar() async {
    return true;
  }
}