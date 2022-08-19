class SalesSharedConfig {
  var allowQuickItem = true;

  SalesSharedConfig();

  SalesSharedConfig.fromJson(Map<String, dynamic> json) {
    allowQuickItem = json['allowQuickItem'];
  }

  Map<String, dynamic> toJson() => {'allowQuickItem': allowQuickItem};
}

class SalesLocalConfig {
  var allowDiscounts = true;
}

class SalesConfig {
  var shared = SalesSharedConfig();
  var local = SalesLocalConfig();
}
