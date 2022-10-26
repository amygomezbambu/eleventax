import 'package:nanoid/nanoid.dart';

class UID {
  String _identifier = '';
  static const _invalidIdentifier = '0';
  static const _nanoIdAlphabet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-';

  UID([String uid = '']) {
    if (uid.isEmpty) {
      _identifier = customAlphabet(_nanoIdAlphabet, 21);
    } else {
      _identifier = uid;
    }
  }

  UID.invalid() {
    _identifier = _invalidIdentifier;
  }

  bool isInvalid() {
    return _identifier == _invalidIdentifier;
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
