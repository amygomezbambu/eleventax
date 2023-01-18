import 'package:eleventa/dependencias.dart';
import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:eleventa/modulos/common/app/interface/red.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/telemetria/infra/repositorio_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/repositorio_telemetria.dart';
import 'package:eleventa/modulos/telemetria/interface/telemetria.dart';
import 'package:eleventa/modulos/common/infra/adaptador_dispositivo.dart';
import 'package:eleventa/modulos/common/infra/adaptador_sqlite.dart';
import 'package:eleventa/modulos/telemetria/infra/adaptador_telemetria.dart';
import 'package:eleventa/modulos/common/infra/logger.dart';
import 'package:eleventa/modulos/common/infra/network/adaptador_red.dart';
import 'package:eleventa/modulos/notificaciones/infra/repositorio_notificaciones.dart';
import 'package:eleventa/modulos/notificaciones/interfaces/repositorio_notificaciones.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/infra/repositorio_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_consulta_productos.dart';
import 'package:eleventa/modulos/productos/interfaces/repositorio_productos.dart';
import 'package:eleventa/modulos/sync/sync.dart';
import 'package:eleventa/modulos/ventas/infra/repositorio_consultas_ventas.dart';
import 'package:eleventa/modulos/ventas/infra/repositorio_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_cosultas_ventas.dart';
import 'package:eleventa/modulos/ventas/interfaces/repositorio_ventas.dart';

class DependenciasLoader {
  static void init() {
    Dependencias.registrar(
      (ILogger).toString(),
      () => Logger.instance,
    );
    Dependencias.registrar(
      (IAdaptadorDeBaseDeDatos).toString(),
      () => AdaptadorSQLite.instance,
    );
    Dependencias.registrar(
      (ISync).toString(),
      () => Sync.getInstance(),
    );
    Dependencias.registrar(
      (IAdaptadorDeTelemetria).toString(),
      () => AdaptadorDeTelemetria.instance,
    );
    Dependencias.registrar(
      (IAdaptadorDeDispositivo).toString(),
      () => AdaptadorDeDispositivo.instance,
    );
    Dependencias.registrar(
      (IRed).toString(),
      () => AdaptadorRed.instance,
    );

    Dependencias.registrar(
      (IRepositorioConsultaVentas).toString(),
      () => RepositorioConsultaVentas(
        db: Dependencias.infra.database(),
        logger: Dependencias.infra.logger(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioVentas).toString(),
      () => RepositorioVentas(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
        consultas: Dependencias.ventas.repositorioConsultasVentas(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioProductos).toString(),
      () => RepositorioProductos(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
      ),
    );
    Dependencias.registrar(
      (IRepositorioConsultaProductos).toString(),
      () => RepositorioConsultaProductos(
        db: Dependencias.infra.database(),
        logger: Dependencias.infra.logger(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioNotificaciones).toString(),
      () => RepositorioNotificaciones(
        syncAdapter: Dependencias.infra.sync(),
        db: Dependencias.infra.database(),
      ),
    );

    Dependencias.registrar(
      (IRepositorioTelemetria).toString(),
      () => RepositorioTelemetria(
        Dependencias.infra.sync(),
        Dependencias.infra.database(),
      ),
    );
  }
}
