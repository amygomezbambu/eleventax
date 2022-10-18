enum Feature {
  productos,
  ventas,
  inventario,
}

extension FlagExtension on Feature {
  bool estaHabilitado() {
    switch (this) {
      case Feature.productos:
        var valor = const String.fromEnvironment('FEATURE_PRODUCTOS',
            defaultValue: "0");
        return (valor == "1");
      case Feature.ventas:
        return true;
      case Feature.inventario:
        return true;
    }
  }
}
