class SyncUniqueRule {
  final String _dataset;
  final String _column;

  String get dataset => _dataset;
  String get column => _column;

  SyncUniqueRule({
    required String dataset,
    required String column,
  })  : _dataset = dataset,
        _column = column;

  @override
  String toString() => 'SyncUniqueRule(_dataset: $_dataset, _column: $_column)';
}
