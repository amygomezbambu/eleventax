import 'package:eleventa/modulos/common/exception/excepciones.dart';

enum TiposSyncEx {
  errorGenerico,
  noInicializado,
  configuracionIncorrecta,
  parametrosIncorrectos,
  errorAlSubirEventos,
}

class SyncEx extends AppEx {
  @override
  TiposSyncEx get tipo => tipo_ as TiposSyncEx;
  SyncEx({
    required TiposSyncEx tipo,
    required super.message,
    super.input,
  }) : super(tipo: tipo);
}
