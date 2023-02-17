import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/telemetria/entidad/evento_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/common/app/usecase/usecase.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';
import 'package:eleventa/modulos/ventas/read_models/venta.dart';

class EnviarMetricasDeCobroRequest {
  late VentaDto? venta;
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
    var info = await _dispositivo.obtenerDatos();
    var formasDePago = <String>[];

    // Los nombres de las propiedades de MixPanel se encuentran en:
    // https://help.mixpanel.com/hc/en-us/articles/115004613766
    if (req.venta == null) {
      //no se cobró la venta y no figura en la tabla, por tanto se canceló el proceso
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
    } else {
      //tenemos venta asignada ya cobrada y persistida como documento inmutable
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
    }

    if (conexionDisponible) {
      await _telemetria.nuevoEvento(evento);
    } else {
      await _repo.agregarAQueue(evento);
    }
  }
}
