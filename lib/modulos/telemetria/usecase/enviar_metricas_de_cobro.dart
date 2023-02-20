import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/telemetria/entidad/evento_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';

class EnviarMetricasDeCobroRequest {
  late VentaDto? venta;
  late TipoEventoTelemetria tipo;
}

class EnviarMetricasDeCobro extends Usecase<void> {
  final IAdaptadorDeDispositivo _dispositivo;
  final IAdaptadorDeTelemetria _telemetria;
  final IRepositorioTelemetria _repo;
  var req = EnviarMetricasDeCobroRequest();

  EnviarMetricasDeCobro({
    required IAdaptadorDeDispositivo adaptadorDeDispositivo,
    required IAdaptadorDeTelemetria adaptadorDeTelemetria,
    required IRepositorioTelemetria repo,
  })  : _dispositivo = adaptadorDeDispositivo,
        _telemetria = adaptadorDeTelemetria,
        _repo = repo {
    operation = _operation;
  }

  Future<void> _operation() async {
    EventoTelemetria evento;

    var conexionDisponible = await Utils.red.hayConexionAInternet();
    var logger = Dependencias.infra.logger();
    var info = await _dispositivo.obtenerDatos();
    var formasDePago = <String>[];

    switch (req.tipo) {
      case TipoEventoTelemetria.cobroCancelado:
        evento = EventoTelemetria(
          uid: UID(),
          tipo: TipoEventoTelemetria.cobroCancelado,
          ip: info.ip,
          propiedades: {
            '\$device': info.nombre,
            '\$user_id': appConfig.negocioID,
            'Sucursal ID': appConfig.sucursalID,
          },
        );
        break;
      case TipoEventoTelemetria.cobroRealizado:
        if (req.venta == null) {
          logger.warn(ValidationEx(
            tipo: TipoValidationEx.argumentoInvalido,
            mensaje: 'La venta no puede ser nula al enviar un evento de cobro',
          ));
        }

        for (var pago in req.venta!.pagos) {
          if (!formasDePago.contains(pago.forma)) {
            formasDePago.add(pago.forma);
          }
        }

        evento = EventoTelemetria(
          uid: UID(),
          tipo: TipoEventoTelemetria.cobroRealizado,
          ip: info.ip,
          propiedades: {
            //TODO: Meter propiedades comunes en el evento (device, user_id, Sucursal_id)
            '\$device': info.nombre,
            '\$user_id': appConfig.negocioID,
            'Sucursal ID': appConfig.sucursalID,
            'Venta UID': req.venta?.uid.toString(),
            'Subtotal': req.venta?.subtotal.importeCobrable.toString(),
            'Total Impuestos':
                req.venta?.totalImpuestos.importeCobrable.toString(),
            'Total': req.venta?.total.importeCobrable.toString(),
            'Numero De Articulos': req.venta?.articulos.length.toString(),
            'Formas De Pago': formasDePago.toString(),
          },
        );
        break;
      default:
        logger.warn(ValidationEx(
          tipo: TipoValidationEx.argumentoInvalido,
          mensaje: 'Tipo de evento de telemetría inválido',
        ));
        return;
    }
    //TODO: Mover la revision de conexion al método nuevoEvento para no repetirlo en cada casod e uso
    if (conexionDisponible) {
      await _telemetria.nuevoEvento(evento);
    } else {
      await _repo.agregarAQueue(evento);
    }
  }
}
