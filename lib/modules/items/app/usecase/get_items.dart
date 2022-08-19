import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/app/mapper/item_mapper.dart';

class GetItems extends Usecase<List<ItemDTO>> {
  final IItemRepository _repo;

  GetItems(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<List<ItemDTO>> _doOperation() async {
    var items = <ItemDTO>[];

    var dbItems = await _repo.getAll();

    for (var item in dbItems) {
      items.add(ItemMapper.fromDomainToDTO(item));
    }

    return items;
  }
}
