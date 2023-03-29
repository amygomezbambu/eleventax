import 'dart:async';
import 'dart:io';

import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/remote_config.dart';
import 'package:eleventa/modulos/config/env.dart';
import 'package:flagsmith/flagsmith.dart';

class RemoteConfig implements IRemoteConfig {
  late final FlagsmithClient _flagsmithClient;
  late final _featureFlags = <FeatureFlag, bool>{};
  final _logger = Dependencias.infra.logger();

  /* #region Singleton */
  static final RemoteConfig instance = RemoteConfig._();

  RemoteConfig._() {
    //
  }
  /* #endregion */

  @override
  Future<void> iniciar() async {
    _logger.info('Iniciando remote config...');
    const config = FlagsmithConfig(isDebug: false);

    // Solo inicializamos si no estamos en pruebas unitarias
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _flagsmithClient = await FlagsmithClient.init(
        apiKey: Env.flagsmithKey,
        config: config,
        seeds: [],
      );

      _logger.info('Obteniendo feature flags...');
      await _flagsmithClient.getFeatureFlags(reload: true);
      await _obtenerFlags();
    }
  }

  Future<void> _obtenerFlags() async {
    // Obtenemos los features booleanos
    for (var featureFlag in FeatureFlag.values) {
      final nombreSinPrefijoEnum =
          featureFlag.toString().replaceFirst(r'FeatureFlag.', '');

      final valor =
          await _flagsmithClient.isFeatureFlagEnabled(nombreSinPrefijoEnum);

      _logger.info('> "$nombreSinPrefijoEnum " : $valor');
      _featureFlags[featureFlag] = valor;
    }
  }

  @override
  bool tieneFeatureFlag(FeatureFlag feature) {
    if (_featureFlags.containsKey(feature)) {
      return _featureFlags[feature]!;
    } else {
      return false;
    }
  }
}
