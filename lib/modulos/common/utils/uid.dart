import 'package:nanoid/nanoid.dart';

class UID {
  String _identifier = '';

  UID([String uid = '']) {
    if (uid.isEmpty) {
      _identifier = nanoid();
    } else {
      _identifier = uid;
    }
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is UID && (toString() == other.toString());
  }

  @override
  String toString() {
    return _identifier;
  }
}
