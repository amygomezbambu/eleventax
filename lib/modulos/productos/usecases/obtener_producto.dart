
// enum TipoDeBusqueda { uid, codigo }

// class ObtenerProductoReq {
//   String? codigo;
//   UID? uidProducto;
//   TipoDeBusqueda tipoDeBusqueda = TipoDeBusqueda.uid;
// }

// class ObtenerProducto extends Usecase<Producto> {
//   final IRepositorioProductos _productos;
//   final req = ObtenerProductoReq();

//   ObtenerProducto(this._productos) : super(_productos) {
//     operation = _operation;
//   }

//   Future<Producto> _operation() async {
//     Producto? producto;

//     switch (req.tipoDeBusqueda) {
//       case TipoDeBusqueda.codigo:
//         if (req.codigo == null) {
//           throw AppEx(message: 'El codigo del producto es nulo');
//         }
//         producto = await _productos.obtenerPorCodigo(req.codigo!);
//         break;
//       case TipoDeBusqueda.uid:
//         if (req.uidProducto == null) {
//           throw AppEx(message: 'El UID del producto es nulo');
//         }

//         producto = await _productos.obtener(req.uidProducto!);
//         break;
//     }

//     if (producto == null) {
//       String message;
//       switch (req.tipoDeBusqueda) {
//         case TipoDeBusqueda.codigo:
//           message = 'El Codigo de producto ${req.codigo} no se encontró';
//           break;
//         case TipoDeBusqueda.uid:
//           message = 'El UID de producto ${req.uidProducto} no se encontró';
//           break;
//       }

//       throw AppEx(message: message);
//     }

//     return producto;
//   }
// }
