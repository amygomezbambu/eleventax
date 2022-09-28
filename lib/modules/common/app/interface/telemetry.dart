enum TelemetryEvent {
  appStarted('appStarted'),
  appFailed('appFailed');

  const TelemetryEvent(this.name);
  final String name;
}

abstract class ITelemetryAdapter {
  Future<void> sendEvent(TelemetryEvent event,
      [Map<String, dynamic> properties]);
}
