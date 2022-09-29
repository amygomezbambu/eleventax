import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/entity/articulo_de_venta.dart';

enum EstadoDeVenta { abierta, pagada, cancelada }

enum MetodoDePago { sinDefinir, efectivo, tarjeta }

class Venta extends Entidad {
  var _nombre = '';
  var _total = 0.0;
  final _articulos = <ArticuloDeVenta>[];
  MetodoDePago? _metodoDePago;
  int? _fechaDePago;
  EstadoDeVenta _status = EstadoDeVenta.abierta;

  double get total => _total;
  String get nombre => _nombre;
  MetodoDePago? get metodoDePago => _metodoDePago;
  int? get fechaDePago => _fechaDePago;
  EstadoDeVenta get status => _status;

  List<ArticuloDeVenta> get articulos => List.unmodifiable(_articulos);
  int get numeroDeArticulos => _articulos.length;

  Venta.crear() : super.crear();

  Venta.cargar({
    required UID uid,
    required String nombre,
    required double total,
    required EstadoDeVenta status,
    MetodoDePago? metodoDePago,
    int? fechaDePago,
    List<ArticuloDeVenta>? articulos,
  }) : super.cargar(uid) {
    _nombre = nombre;
    _total = total;
    _status = status;
    _metodoDePago = metodoDePago;
    _fechaDePago = fechaDePago;
  }

  void agregarArticulo(ArticuloDeVenta item) {
    _articulos.add(item);

    calcularTotal();
  }

  void cobrar(MetodoDePago metodoDePago) {
    _metodoDePago = metodoDePago;
    _fechaDePago = DateTime.now().millisecondsSinceEpoch;
    _status = EstadoDeVenta.pagada;
  }

  void calcularTotal() {
    _total = 0.0;

    for (var articulo in _articulos) {
      _total += articulo.total;
    }
  }
}
