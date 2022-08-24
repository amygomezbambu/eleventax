// ignore_for_file: unnecessary_getters_setters

import 'package:eleventa/modules/common/infra/local_config.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

class SalesSharedConfig {
  UID _uid = UID();
  var _allowQuickItem = true;

  UID get uid => _uid;
  bool get allowQuickItem => _allowQuickItem;

  set allowQuickItem(bool value) {
    _allowQuickItem = value;
  }

  SalesSharedConfig();

  SalesSharedConfig.load(UID uid, Map<String, dynamic> jsonValues)
      : _allowQuickItem = jsonValues['allowQuickItem'],
        _uid = uid;

  Map<String, dynamic> toJson() => {'allowQuickItem': _allowQuickItem};
}

class SalesLocalConfig extends LocalConfig {
  var _allowDiscounts = true;

  set allowDiscounts(bool value) {
    _allowDiscounts = value;
  }

  bool get allowDiscounts => _allowDiscounts;

  SalesLocalConfig();

  Map<String, Object> toMap() {
    return {'allowDiscounts': _allowDiscounts};
  }
}

class SalesConfig {
  SalesSharedConfig shared = SalesSharedConfig();
  SalesLocalConfig local = SalesLocalConfig();
}
