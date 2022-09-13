// ignore_for_file: unnecessary_getters_setters

import 'package:eleventa/modules/common/infra/local_config.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

class SalesSharedConfig {
  UID _uid = UID();
  var _allowQuickItem = true;
  var _allowZeroCost = true;

  UID get uid => _uid;
  bool get allowQuickItem => _allowQuickItem;
  bool get allowZeroCost => _allowZeroCost;

  set allowQuickItem(bool value) {
    _allowQuickItem = value;
  }

  SalesSharedConfig();

  SalesSharedConfig.load({required UID uid, required bool allowQuickItem, required bool allowZeroCost})
      : _uid = uid, _allowQuickItem = allowQuickItem, _allowZeroCost = allowZeroCost;
      
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
