import 'package:eleventa/globals.dart';

enum Feature {
  catalogoDeProductos,
  ventas,
}

extension FlagExtension on Feature {
  bool estaHabilitado() {
    var env = appConfig.ambiente;

    switch (env) {
      case 'dev':
        switch (this) {
          case Feature.catalogoDeProductos:
            return true;
          case Feature.ventas:
            return true;
        }
      case 'prod':
        switch (this) {
          case Feature.catalogoDeProductos:
            return false;
          case Feature.ventas:
            return false;
        }
    }

    return false;
  }
}
