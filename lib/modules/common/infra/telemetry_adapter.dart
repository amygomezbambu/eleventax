import 'package:eleventa/modules/common/app/interface/logger.dart';
import 'package:eleventa/modules/common/app/interface/telemetry.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:eleventa/dependencies.dart';
import 'dart:async';

import 'package:eleventa/globals.dart';

class TelemetryAdapter implements ITelemetryAdapter {
  MixpanelAnalytics? _mixpanel;
  String _token = '';

  final ILogger _logger = Dependencies.infra.logger();

  TelemetryAdapter({String token = ''}) {
    _token = token;

    _initializeMixPanel();
  }

  @override
  Future<void> sendEvent(TelemetryEvent event,
      [Map<String, dynamic> properties = const {}]) async {
    var success =
        await _mixpanel!.track(event: event.name, properties: properties);

    if (!success) {
      throw EleventaException(
        message: 'No se registro el evento ${event.name}',
      );
    }
  }

  void _initializeMixPanel() {
    final user$ = StreamController<String>.broadcast();

    _mixpanel = MixpanelAnalytics(
      token: _token.isNotEmpty ? _token : appConfig.secrets.telemetryToken,
      userId$: user$.stream,
      verbose: true,
      shouldAnonymize: false,
      shaFn: (value) => value,
      onError: (e) => {_logger.error(ex: e)},
    );

    user$.add(appConfig.deviceId.toString());
  }
}
