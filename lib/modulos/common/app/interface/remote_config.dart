// Feature Flags activos
enum FeatureFlag {
  sincronizacion,
  impuestos,
}

abstract class IRemoteConfig {
  Future<void> iniciar();

  bool tieneFeatureFlag(FeatureFlag feature);
}
