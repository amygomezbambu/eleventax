import 'package:eleventa/modules/common/domain/entity.dart';
import 'package:eleventa/modules/common/utils/uid.dart';

class Item extends Entity {
  var _description = '';
  var _price = 0.0;
  var _sku = '';

  String get description => _description;
  double get price => _price;
  String get sku => _sku;

  Item.create({
    required String description,
    required double price,
    required String sku,
  }) : super.create() {
    _validateDescription(description);
    _validatePrice(price);
    _validateSku(sku);
  }

  Item.load(
    UID uid,
    String sku,
    String description,
    double price,
  ) : super.load(uid) {
    _validateDescription(description);
    _validatePrice(price);
    _validateSku(sku);
  }

  void _validateDescription(String value) {
    if (value.isEmpty) {
      throw Exception('La descripcion no puede estar vacia');
    }

    _description = value;
  }

  void _validatePrice(double value) {
    if (value <= 0) {
      throw Exception('El precio no pude ser cero');
    }

    _price = value;
  }

  void _validateSku(String value) {
    if (value.isEmpty) {
      throw Exception('El sku no puede ser vacío');
    }

    _sku = value;
  }
}
