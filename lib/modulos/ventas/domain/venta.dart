import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';

enum EstadoDeVenta { enProgreso, cobrada, cancelada }

class Venta extends Entidad {
  final EstadoDeVenta _estado;
  final DateTime _creadoEn;

  EstadoDeVenta get estado => _estado;
  DateTime get creadoEn => _creadoEn;

  Venta.cargar({
    required UID uid,
    required EstadoDeVenta estado,
    required DateTime creadoEn,
  })  : _estado = estado,
        _creadoEn = creadoEn,
        super.cargar(uid);

  Venta.crear()
      : _estado = EstadoDeVenta.enProgreso,
        _creadoEn = DateTime.now(),
        super.crear();
}
