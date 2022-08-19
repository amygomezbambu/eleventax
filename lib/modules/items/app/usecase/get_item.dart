import 'package:eleventa/modules/common/app/usecase/usecase.dart';
import 'package:eleventa/modules/common/exception/exception.dart';

import 'package:eleventa/modules/items/app/dto/item_dto.dart';
import 'package:eleventa/modules/items/app/interface/item_repository.dart';
import 'package:eleventa/modules/items/domain/entity/item.dart';
import 'package:eleventa/modules/items/app/mapper/item_mapper.dart';

class GetItemRequest {
  String sku = '';
}

class GetItem extends Usecase<ItemDTO> {
  final IItemRepository _repo;
  final request = GetItemRequest();

  GetItem(this._repo) : super(_repo) {
    operation = _doOperation;
  }

  Future<ItemDTO> _doOperation() async {
    Item? item = await _repo.getBySku(request.sku);

    if (item == null) {
      final errorMessage =
          'El Codigo de producto ${request.sku} no se encontró';

      logger.error(ex: AppException(message: errorMessage));

      throw AppException(message: errorMessage);
    }

    return ItemMapper.fromDomainToDTO(item);
  }
}
