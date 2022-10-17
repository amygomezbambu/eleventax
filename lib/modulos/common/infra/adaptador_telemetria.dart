import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/telemetria.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:eleventa/dependencias.dart';
import 'dart:async';

import 'package:eleventa/globals.dart';

class AdaptadorDeTelemetria implements IAdaptadorDeTelemetria {
  MixpanelAnalytics? _mixpanel;

  final ILogger _logger = Dependencias.infra.logger();

  /* #region Singleton */
  static final instance = AdaptadorDeTelemetria._();

  AdaptadorDeTelemetria._() {
    _initializeMixPanel();
  }
  /* #endregion */

  @override
  Future<void> nuevoEvento({
    required EventoDeTelemetria evento,
    required Map<String, dynamic> propiedades,
    String? ip,
  }) async {
    var success = await _mixpanel!.track(
      event: evento.name,
      properties: propiedades,
      ip: ip,
    );

    if (!success) {
      throw EleventaEx(
        message: 'No se registro el evento ${evento.name}',
      );
    }
  }

  @override
  Future<void> actualizarPerfil(
      {required Map<String, dynamic> propiedades, String? ip}) async {
    /// Establece la propiedad del perfil del usuario
    /// Ref: https://developer.mixpanel.com/reference/profile-set
    var success = await _mixpanel!.engage(
        operation: MixpanelUpdateOperations.$set, value: propiedades, ip: ip);
    if (!success) {
      throw EleventaEx(message: 'No se creó o actualizó el perfil');
    }
  }

  void _initializeMixPanel() {
    final user$ = StreamController<String>.broadcast();

    _mixpanel = MixpanelAnalytics(
      token: appConfig.secrets.tokenTelemetria,
      userId$: user$.stream,
      verbose: true,
      shouldAnonymize: false,
      shaFn: (value) => value,
      onError: (e) => {_logger.error(ex: e)},
    );

    user$.add(appConfig.deviceId.toString());
  }
}
