// Feature Flags activos
enum FeatureFlag {
  sincronizacion,
  impuestos,
  categorias,
  transacciones,
}

abstract class IRemoteConfig {
  Future<void> iniciar();

  bool tieneFeatureFlag(FeatureFlag feature);
}
