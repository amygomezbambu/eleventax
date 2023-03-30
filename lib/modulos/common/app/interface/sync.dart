enum TipoEventoSync {
  crear,
  actualizar,
  eliminar,
}

abstract class ISync {
  /// Sincroniza eventos.
  ///
  /// Para cada campo [evento.campos[n].nombre] y su respectivo valor [evento.campos[n].valor]
  /// aplica los cambios a la base de datos local en la tabla [evento.dataset] y
  /// el row [evento.rowID] y posteriormente envia el evento al servidor remoto de sincronización
  ///
  /// si [awaitServerResponse] es true, el proceso esperará hasta que reciba respuesta del servidor
  Future<void> sincronizar({
    TipoEventoSync tipo = TipoEventoSync.actualizar,
    required String rowID,
    required String dataset,
    required Map<String, Object?> campos,
    bool awaitServerResponse = false,
  });

  /// Inicia la escucha de nuevos cambios en el servidor remoto
  Future<void> initListening();

  /// Detiene la escucha de nuevos cambios en el servidor remoto
  void stopListening();

  /// Inicia el proceso que observa el queue y reintenta enviar los cambios
  Future<void> initQueueProcessing();

  /// Detiene el procesamiento del Queue
  void stopQueueProcessing();
}
