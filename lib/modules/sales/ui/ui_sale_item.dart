class UiSaleItem {
  final String code;
  final String description;
  final String price;

  UiSaleItem(
      {required this.code, required this.description, required this.price});
}

class UiCart {
  static final List<UiSaleItem> items = [];
  static var total = 12.50;
  static late UiSaleItem selectedItem;

  // UiCart() {

  // }
  static bool isSelectedItem(UiSaleItem item) {
    if (UiCart.selectedItem != null) {
      return selectedItem == item;
    } else {
      return false;
    }
  }
}
