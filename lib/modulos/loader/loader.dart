import 'package:eleventa/dependencias.dart';
import 'package:eleventa/globals.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:eleventa/modulos/common/utils/uid.dart';
import 'package:eleventa/modulos/loader/iniciar_dependencias.dart';
import 'package:eleventa/modulos/loader/iniciar_sincronizacion.dart';
import 'package:eleventa/modulos/migraciones/migrar_db.dart';
import 'package:eleventa/modulos/productos/domain/categoria.dart';
import 'package:eleventa/modulos/productos/domain/impuesto.dart';
import 'package:eleventa/modulos/productos/domain/producto.dart';
import 'package:eleventa/modulos/productos/domain/unidad_medida.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/codigo_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/nombre_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_compra_producto.dart';
import 'package:eleventa/modulos/productos/domain/value_objects/precio_de_venta_producto.dart';
import 'package:eleventa/modulos/telemetria/modulo_telemetria.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';

enum TipoUnidadDeMedida { pieza, granel }

/// Inicializador de la aplicacion
///
/// carga todos los objetos y datos necesarios para que la aplicación
/// funcione correctamente
class Loader {
  late IAdaptadorDeBaseDeDatos adaptadorDB;
  late ILogger logger;

  /* #region Singleton */
  static final Loader _instance = Loader._internal();

  factory Loader() {
    return _instance;
  }

  Loader._internal();
  /* #endregion */

  Future<void> iniciarLogging() async {
    logger = Dependencias.infra.logger();

    await logger.iniciar(
      config: LoggerConfig(
        nivelesRemotos: [NivelDeLog.error],
        nivelesDeArchivo: [NivelDeLog.error, NivelDeLog.warning],
        nivelesDeConsola: [NivelDeLog.all],
      ),
    );
  }

  Future<void> iniciarRemoteConfig() async {
    var featureFlags = Dependencias.infra.remoteConfig();

    await featureFlags.iniciar();
  }

  Future<void> iniciarDB() async {
    adaptadorDB = Dependencias.infra.database();
    await adaptadorDB.conectar();

    var migrarDB = MigrarDB();
    await migrarDB.exec();
  }

  Future<void> enviarMetricasIniciales() async {
    var telemetria = ModuloTelemetria.enviarMetricasIniciales();

    await telemetria.exec();
  }

  Future<void> iniciar() async {
    WidgetsFlutterBinding.ensureInitialized();

    DependenciasLoader.init();

    await _iniciarSistemasCriticos();
    await _iniciarSistemasNoCriticos();
  }

  Future<void> _iniciarSistemasCriticos() async {
    await appConfig.cargar();
    await iniciarLogging();
    await iniciarDB();
    await iniciarRemoteConfig();
    await SincronizacionLoader.iniciar();
  }

  Future<void> _iniciarSistemasNoCriticos() async {
    try {
      await enviarMetricasIniciales();
    } catch (e) {
      logger.error(ex: e);
    }
  }

  Producto crearProductoUtil({
    String? codigo,
    String? nombre,
    Moneda? precioCompra,
    Moneda? precioVenta,
    Categoria? categoria,
    UnidadDeMedida? unidadDeMedida,
    TipoUnidadDeMedida tipoUnidadDeMedida = TipoUnidadDeMedida.pieza,
    List<Impuesto>? impuestos,
  }) {
    var faker = Faker();

    final codigo_ = codigo != null
        ? CodigoProducto(codigo)
        : CodigoProducto(UID().toString());

    final nombre_ = nombre != null
        ? NombreProducto(nombre)
        : NombreProducto(faker.food.dish());

    final precioCompra_ = precioCompra != null
        ? PrecioDeCompraProducto(precioCompra)
        : PrecioDeCompraProducto(Moneda(faker.randomGenerator.decimal(min: 1)));

    final precioVenta_ = precioVenta != null
        ? PrecioDeVentaProducto(precioVenta)
        : PrecioDeVentaProducto(Moneda(faker.randomGenerator.decimal(min: 5)));

    final unidadDeMedida_ = unidadDeMedida ??
        UnidadDeMedida.crear(
          nombre: 'pieza',
          abreviacion: 'pza',
        );
    // final impuestos_ = impuestos ??
    //     <Impuesto>[
    //       Impuesto.crear(
    //           nombre: 'IVA',
    //           porcentaje: PorcentajeDeImpuesto(16.0),
    //           ordenDeAplicacion: 2),
    //     ];

    return Producto.crear(
        codigo: codigo_,
        nombre: nombre_,
        unidadDeMedida: unidadDeMedida_,
        precioDeCompra: precioCompra_,
        precioDeVenta: precioVenta_,
        impuestos: []);
  }
}
