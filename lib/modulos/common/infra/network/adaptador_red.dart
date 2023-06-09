import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/infra/network/conectividad_internet.dart';
import 'package:http/http.dart' as http;

class AdaptadorRed implements IRed {
  final _logger = Dependencias.infra.logger();
  var ipPublica = '';

  /* #region Singleton */
  static final instance = AdaptadorRed._();

  AdaptadorRed._();
  /* #endregion */

  @override
  Future<bool> hayConexionAInternet() async {
    var internet = await ConectividadDeInternet.getInstance();

    return internet.estaConectado;
  }

  @override
  Future<String> obtenerIPPublica() async {
    ipPublica = ipPublica.isNotEmpty ? ipPublica : await _obtenerIPPublica();

    return ipPublica;
  }

  Future<String> _obtenerIPPublica() async {
    try {
      var response = await http.get(
        Uri.parse('https://api.ipify.org'),
      );

      if (response.statusCode != 200) {
        throw InfraEx(
          message: 'No se pudo obtener la IP publica',
          innerException: Exception(response.body),
          stackTrace: StackTrace.current,
          tipo: TipoInfraEx.noSePudoObtenerIP,
        );
      } else {
        ipPublica = response.body;
      }

      return ipPublica;
    } catch (e) {
      _logger.warn(InfraEx(
        message: 'No se pudo obtener IP publica: $e',
        innerException: e,
        tipo: TipoInfraEx.noSePudoObtenerIP,
      ));
      return '127.0.0.1';
    }
  }
}
