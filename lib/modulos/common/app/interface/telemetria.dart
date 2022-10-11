enum EventoDeTelemetria {
  //los eventos siempre se ponen en pasado
  appIniciada('appIniciada'),
  fallaDeApp('fallaDeApp'); //placeholder temporal

  const EventoDeTelemetria(this.nombre);
  final String nombre;
}

abstract class IAdaptadorDeTelemetria {
  /// Agrega un nuevo evento para que sea enviado al servicio de telemetria
  ///
  /// Recibe un evento de telemetria y las propiedades del evento
  Future<void> nuevoEvento(
      {required EventoDeTelemetria evento,
      required Map<String, dynamic> propiedades,
      String? ip});

  /// Establece las propiedades del perfil del usuario en el servicio de telemetria
  /// es decir, el estado actual del usuario
  /// Referencia: https://help.mixpanel.com/hc/en-us/articles/115004708186-Profile-Properties
  Future<void> actualizarPerfil({
    required Map<String, dynamic> propiedades,
    String? ip,
  });
}
