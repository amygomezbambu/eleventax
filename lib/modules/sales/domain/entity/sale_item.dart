import 'package:eleventa/modules/common/domain/valueObject/uid.dart';
import 'package:eleventa/modules/common/exception/exception.dart';
import 'package:meta/meta.dart';

class SaleItem {
  @protected
  late final UID _saleUid;
  @protected
  late final UID? _itemUid;
  @protected
  late String _description;
  @protected
  late double _price;
  @protected
  late double _quantity;

  SaleItem(
      {required UID saleUid,
      UID? itemUid,
      required String description,
      required double price,
      required double quantity}) {
    _saleUid = saleUid;
    _itemUid = itemUid;

    _validateDescription(description);
    _validatePrice(price);
    _validateQuantity(quantity);
  }

  UID get saleUid => _saleUid;
  UID? get itemUid => _itemUid;
  String get description => _description;
  double get price => _price;
  double get quantity => _quantity;
  double get total => _price * _quantity;

  void _validateDescription(String value) {
    if (value.isEmpty) {
      throw DomainException('La descripcion no puede estar vacia');
    }

    _description = value;
  }

  void _validatePrice(double value) {
    if (value <= 0) {
      throw DomainException('El precio no pude ser cero');
    }

    _price = value;
  }

  void _validateQuantity(double value) {
    if (value <= 0) {
      throw DomainException('La cantidad no pude ser cero');
    }

    _quantity = value;
  }
}
