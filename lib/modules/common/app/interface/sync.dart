abstract class ISync {
  /// Sincroniza los cambios.
  ///
  /// Para cada columna en [fields] y su respectivo valor en [values]
  /// aplica los cambios a la base de datos local en la tabla [dataset] y
  /// el row [rowID] y posteriormente los envia al servidor remoto de sincronización
  Future<void> syncChanges({
    required String dataset,
    required String rowID,
    required Map<String, Object?> fields,
  });

  /// Inicia la escucha de nuevos cambios en el servidor remoto
  Future<void> initListening();

  /// Detiene la escucha de nuevos cambios en el servidor remoto
  void stopListening();
}
