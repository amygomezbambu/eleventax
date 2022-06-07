import 'package:uuid/uuid.dart';

class Item {
  var _description = '';
  var _price = 0.0;
  var _sku = '';
  var _uid = const Uuid().v4();

  String get uid => _uid;

  String get description {
    return _description;
  }

  double get price {
    return _price;
  }

  String get sku {
    return _sku;
  }

  Item(
      {required String description,
      required double price,
      required String sku}) {
    _setDescription(description);
    _setPrice(price);
    _setSku(sku);
  }

  Item.load(String uid, String sku, String description, double price) {
    _uid = uid;
    _sku = sku;
    _description = description;
    _price = price;
  }

  void _setDescription(String value) {
    if (value.isEmpty) {
      throw Exception('La descripcion no puede estar vacia');
    }

    _description = value;
  }

  void _setPrice(double value) {
    if (value <= 0) {
      throw Exception('El precio no pude ser cero');
    }

    _price = value;
  }

  void _setSku(String value) {
    if (value.isEmpty) {
      throw Exception('El sku no puede ser vacío');
    }

    _sku = value;
  }
}
