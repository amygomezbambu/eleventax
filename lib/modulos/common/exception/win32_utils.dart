import 'package:eleventa/modulos/common/exception/excepciones.dart';

Exception generarExcepcionDeErrorWin32([int? errorCode]) {
  return EleventaEx(
    message: errorCode != null ? 'GetLastError: $errorCode' : '',
    tipo_: TipoInfraEx.win32Exception,
    stackTrace: StackTrace.current,
  );
}
