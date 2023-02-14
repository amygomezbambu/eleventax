import 'package:eleventa/modulos/common/domain/entidad.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/exception/excepciones.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/ventas/domain/forma_de_pago.dart';

class Pago extends Entidad {
  final FormaDePago _forma;
  final Moneda _monto;
  final Moneda? _pagoCon;
  final String? _referencia;

  FormaDePago get forma => _forma;
  Moneda get monto => _monto;
  Moneda? get pagoCon => _pagoCon;
  String? get referencia => _referencia;

  Pago.crear({
    required FormaDePago forma,
    required Moneda monto,
    Moneda? pagoCon,
    String? referencia,
  })  : _forma = forma,
        _monto = monto,
        _pagoCon = pagoCon,
        _referencia = referencia,
        super.crear() {
    _validarMonto(monto);
  }

  Pago.cargar({
    required UID uid,
    required FormaDePago forma,
    required Moneda monto,
    Moneda? pagoCon,
    String? referencia,
  })  : _forma = forma,
        _monto = monto,
        _pagoCon = pagoCon,
        _referencia = referencia,
        super.cargar(uid);

  void _validarMonto(Moneda value) {
    if (value <= Moneda(0)) {
      throw ValidationEx(
          // TODO: Ver si lanzamos validacion de valor mayor a cero
          tipo: TipoValidationEx.errorDeValidacion,
          mensaje: 'El monto del pago debe ser mayor a cero');
    }
  }
}
