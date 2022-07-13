import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/app/mapper/item_mapper.dart';

class GetItems {
  final IItemRepository _repo;

  GetItems(this._repo);

  Future<List<ItemDTO>> exec() async {
    var items = <ItemDTO>[];

    var dbItems = await _repo.getAll();

    for (var item in dbItems) {
      items.add(ItemMapper.fromDomainToDTO(item));
    }

    return items;
  }
}
