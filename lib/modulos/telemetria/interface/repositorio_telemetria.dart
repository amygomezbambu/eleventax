import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/telemetria/entidad/evento_telemetria.dart';

abstract class IRepositorioTelemetria {
  Future<void> agregarAQueue(EventoTelemetria evento);
  Future<void> eliminarDeQueue(UID uid);
}
