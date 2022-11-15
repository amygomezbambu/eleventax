import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//crear notificador
class NotificadorListadoProductos extends StateNotifier<List<Producto>> {
  var consultas = Dependencias.productos.repositorioConsultasProductos();

  NotificadorListadoProductos() : super(<Producto>[]) {
    obtenerProductos();
  }

  void obtenerProductos() {
    consultas.obtenerProductos().then((productos) => state = productos);
  }
}

//crear provider

final providerListadoProductos =
    StateNotifierProvider<NotificadorListadoProductos, List<Producto>>(
        (ref) => NotificadorListadoProductos());
