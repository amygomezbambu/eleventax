import 'package:eleventa/modules/common/exception/exception.dart';

class BasicItem {
  var _description = '';
  var _price = 0.0;
  var _quantity = 0.0;

  String get description {
    return _description;
  }

  double get price {
    return _price;
  }

  double get quantity {
    return _quantity;
  }

  double get total {
    return _price * _quantity;
  }

  BasicItem(
      {required String description,
      required double price,
      required double quantity}) {
    _setDescription(description);
    _setPrice(price);
    _setQuantity(quantity);
  }

  void _setDescription(String value) {
    if (value.isEmpty) {
      throw DomainException('La descripcion no puede estar vacia');
    }

    _description = value;
  }

  void _setPrice(double value) {
    if (value <= 0) {
      throw DomainException('El precio no pude ser cero');
    }

    _price = value;
  }

  void _setQuantity(double value) {
    if (value <= 0) {
      throw DomainException('La cantidad no pude ser cero');
    }

    _quantity = value;
  }
}
