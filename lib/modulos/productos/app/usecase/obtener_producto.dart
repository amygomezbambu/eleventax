class ObtenerProductoReq {
  String sku = '';
}

// class ObtenerProducto extends Usecase<ProductoDTO> {
//   final IRepositorioArticulos _repo;
//   final req = ObtenerProductoReq();

//   ObtenerProducto(this._repo) : super(_repo) {
//     operation = _operation;
//   }

//   Future<ProductoDTO> _operation() async {
//     Producto? producto = await _repo.obtenerPorSKU(req.sku);

//     if (producto == null) {
//       final message = 'El Codigo de producto ${req.sku} no se encontró';

//       logger.error(ex: AppEx(message: message));

//       throw AppEx(message: message);
//     }

//     //return ProductoMapper.domainAData(producto);
//   }
// }
