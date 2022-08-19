import 'package:eleventa/modules/common/utils/uid.dart';
import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';

class ItemMapper {
  static ItemDTO fromDomainToDTO(Item item) {
    var dto = ItemDTO();
    dto.description = item.description;
    dto.price = item.price;
    dto.sku = item.sku;
    dto.uid = item.uid.toString();

    return dto;
  }

  static Map<String, Object?> fromDomainToMap(Item item) {
    return <String, Object?>{
      'uid': item.uid.toString(),
      'description': item.description,
      'price': item.price,
      'sku': item.sku
    };
  }

  /// Convierte un row de sqlite a una entidad de dominio
  ///
  /// ***IMPORTANTE*** esta implementación esta acoplada a SQLite y al paquete
  /// [Sqflite], si se decide desacoplar el mapeador, tendriamos que crear uno
  /// exclusivo para la base de datos que estuviera incluido en la implementación,
  /// de esa manera al cambiar la db cambiaria automaticamente el mapeador.
  static Item fromDatabaseToDomain(Map<String, Object?> dbRow) {
    return Item.load(
      UID(dbRow['uid'] as String),
      dbRow['sku'] as String,
      dbRow['description'] as String,
      dbRow['price'] as double,
    );
  }
}
