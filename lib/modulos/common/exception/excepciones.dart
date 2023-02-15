import 'package:flutter/foundation.dart';

enum TipoEleventaEx { errorGenerico }

class EleventaEx implements Exception {
  // TODO: Cambiar por debugMessage
  String message;
  String? what;
  String? where;
  String? why;
  String? solution;
  StackTrace? stackTrace;
  Object? innerException;
  @protected
  final Enum tipo_;

  Enum get tipo => tipo_;

  /// representa los datos que fueron proporcionados al metodo que causo el error
  String? input;

  //TODO: Considerar que message ya no sea required
  EleventaEx({
    required this.message,
    required this.tipo_,
    this.innerException,
    this.stackTrace,
    this.input,
  }) {
    stackTrace ??= StackTrace.current;
  }

  @override
  String toString() {
    return '${runtimeType.toString()}: $message\n';
  }
}

class DomainEx extends EleventaEx {
  DomainEx(String message, Enum tipo) : super(message: message, tipo_: tipo);
}

enum TipoValidationEx {
  errorDeValidacion,
  valorReservado,
  argumentoInvalido,
  valorVacio,
  valorEnCero,
  longitudInvalida,
  valorNegativo,
  valorFueraDeRango,
  entidadYaExiste,
  entidadNoExiste,
}

class ValidationEx extends DomainEx {
  @override
  TipoValidationEx get tipo => tipo_ as TipoValidationEx;

  ValidationEx({required String mensaje, required Enum tipo})
      : super(mensaje, tipo);
}

class AppEx extends EleventaEx {
  AppEx({
    required String message,
    String? input,
    required Enum tipo,
  }) : super(message: message, input: input, tipo_: tipo);
}

enum TipoInfraEx {
  errorConsultaDB,
  errorInicializacionDB,
  errorConfiguracionDB,
  noSePudoObtenerIP,
}

class InfraEx extends EleventaEx {
  InfraEx({
    required String message,
    required Object innerException,
    StackTrace? stackTrace,
    String? input,
    required Enum tipo,
  }) : super(
          message: message,
          innerException: innerException,
          stackTrace: stackTrace,
          input: input,
          tipo_: tipo,
        );
}

// TODO: Mover a su propio lado
enum TiposProductosEx {
  yaExisteEntidad,
}

class ProductosEx extends AppEx {
  @override
  TiposProductosEx get tipo => tipo_ as TiposProductosEx;
  ProductosEx({
    required TiposProductosEx tipo,
    required super.message,
    super.input,
  }) : super(tipo: tipo);
}
