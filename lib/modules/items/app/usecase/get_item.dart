import 'package:eleventa/dependencies.dart';
import 'package:eleventa/modules/common/exception/exception.dart';

import '../dto/item_dto.dart';
import '../interface/item_repository.dart';
import '../../domain/entity/item.dart';
import '../mapper/item_mapper.dart';

class GetItemRequest {
  String sku = '';
}

class GetItem {
  final _logger = Dependencies.infra.logger();
  final IItemRepository _repo;
  GetItemRequest request = GetItemRequest();

  GetItem(this._repo);

  Future<ItemDTO> exec() async {
    Item? item = await _repo.getBySku(request.sku);

    if (item == null) {
      _logger.error(EleventaException('Codigo de producto invalido', null));
      throw AppException('Codigo de producto invalido');
    }

    return ItemMapper.fromDomainToDTO(item);
  }
}
