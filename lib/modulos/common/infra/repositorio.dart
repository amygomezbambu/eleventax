import 'package:eleventa/modulos/common/app/interface/database.dart';
import 'package:eleventa/modulos/common/app/interface/sync.dart';
import 'package:eleventa/modulos/common/domain/moneda.dart';
import 'package:meta/meta.dart';

class DiferenciaListas<T> {
  List<T> agregados = [];
  List<T> eliminados = [];
}

class Repositorio {
  @protected
  late IAdaptadorDeBaseDeDatos db;
  @protected
  late ISync adaptadorSync;

  Repositorio(this.adaptadorSync, this.db);

  /// Obtiene las diferencias entre 2 listas que representan la relacion de 2 entidades
  ///
  /// [listaMemoria] contiene los valores relacionados de la entidad en memoria
  /// [listaDatabase] contiene los valores relacionados de la base de datos
  ///
  /// Por ejemplo: una entidad Producto tiene una lista de impuestos relacionados,
  /// si pasas los impuestos de la entidad en memoria y los impuestos de una entidad
  /// leida de la base de datos este metodo retornara un objeto que contiene las nuevas
  /// relaciones y las relaciones que fueron eliminadas.
  ///
  /// Las nuevas relaciones son las que estan en la entidad en memoria y que no existen
  /// en la base de dato.
  ///
  /// Las relaciones eliminadas son las que existen en la base de datos pero ya no estan
  /// en la entidad en memoria.
  DiferenciaListas<T> obtenerDiferenciasDeListasDeRelaciones<T>(
    List<T> listaMemoria,
    List<T> listaDatabase,
  ) {
    var diferencias = DiferenciaListas<T>();

    for (var item in listaMemoria) {
      var itemsDb = listaDatabase.where((itemDb) => itemDb == item).toList();

      if (itemsDb.isEmpty) {
        diferencias.agregados.add(item);
      }
    }

    for (var item in listaDatabase) {
      var itemsMemoria =
          listaMemoria.where((itemMemoria) => itemMemoria == item).toList();

      if (itemsMemoria.isEmpty) {
        diferencias.eliminados.add(item);
      }
    }

    return diferencias;
  }

  /// Obtiene un mapa con las diferencias entre la entidad modificada y la entidad en la db
  ///
  /// [camposEntidad] representa el estado en memoria
  /// [camposDb] representa el estado almacenado en la base de datos
  ///
  /// NOTA: no obtiene diferencias entre listas o iterables, por ejemplo un Producto
  /// puede tener N impuestos, la lista de impuestos no se comparará correctamente, se
  /// debe usar obtenerDiferenciasDeListasDeRelaciones para cada propiedad que sea una lista.
  ///
  /// El campo UID se ignora ya que la sincronización espera que se pase dentro del parametro
  /// rowID
  Future<Map<String, Object?>> obtenerDiferencias(
    Map<String, Object?> camposEntidad,
    Map<String, Object?> camposDb,
  ) async {
    Map<String, Object?> diferencias = {};

    for (var field in camposDb.keys) {
      if (camposEntidad[field] is List<Object>) {
        continue;
      }

      if (field == 'uid') {
        continue;
      }

      if (camposEntidad[field] != camposDb[field]) {
        diferencias[field] = camposEntidad[field];
      }
    }

    //El motor de sincronización y la db no trabajan con entidades o value objects
    //directamente por lo que debemos convertir los tipos especiales a un tipo que ellos
    //entiendan
    for (var diferencia in diferencias.keys) {
      if (diferencias[diferencia] is Moneda) {
        diferencias[diferencia] =
            (diferencias[diferencia] as Moneda).serialize();
      }
    }

    return diferencias;
  }

  Future<void> transaction() async {
    await db.transaction();
  }

  Future<void> commit() async {
    await db.commit();
  }

  Future<void> rollback() async {
    await db.rollback();
  }
}
