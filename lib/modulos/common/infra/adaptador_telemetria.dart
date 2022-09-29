import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:eleventa/dependencias.dart';
import 'dart:async';

import 'package:eleventa/globals.dart';

class AdaptadorDeTelemetria implements IAdaptadorDeTelemetria {
  MixpanelAnalytics? _mixpanel;
  String _token = '';

  final ILogger _logger = Dependencias.infra.logger();

  AdaptadorDeTelemetria({String token = ''}) {
    _token = token;

    _initializeMixPanel();
  }

  @override
  Future<void> nuevoEvento(EventoDeTelemetria event,
      [Map<String, dynamic> properties = const {}]) async {
    var success =
        await _mixpanel!.track(event: event.name, properties: properties);

    if (!success) {
      throw EleventaEx(
        message: 'No se registro el evento ${event.name}',
      );
    }
  }

  void _initializeMixPanel() {
    final user$ = StreamController<String>.broadcast();

    _mixpanel = MixpanelAnalytics(
      token: _token.isNotEmpty ? _token : appConfig.secrets.tokenTelemetria,
      userId$: user$.stream,
      verbose: true,
      shouldAnonymize: false,
      shaFn: (value) => value,
      onError: (e) => {_logger.error(ex: e)},
    );

    user$.add(appConfig.deviceId.toString());
  }
}
