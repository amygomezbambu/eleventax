import '../dto/item_dto.dart';
import '../interface/item_repository.dart';
import '../../domain/entity/item.dart';
import '../mapper/item_mapper.dart';

class GetItemRequest {
  String sku = '';
}

class GetItem {
  final IItemRepository _repo;
  GetItemRequest request = GetItemRequest();

  GetItem(this._repo);

  Future<ItemDTO> exec() async {
    Item? item = await _repo.getBySku(request.sku);

    if (item == null) {
      throw Exception('Codigo de producto invalido');
    }

    return ItemMapper.fromDomainToDTO(item);
  }
}
