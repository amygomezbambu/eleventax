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
  Future<void> nuevoEvento(EventoDeTelemetria evento,
      [Map<String, dynamic> propiedades]);
}
