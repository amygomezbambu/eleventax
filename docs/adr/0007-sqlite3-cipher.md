**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

El usuario siempre querrá que la información de su negocio, ventas, ganancias, etc sea totalmente privada y tener un control absoluto de quien tiene acceso a esta información.

- La base de datos de eleventa clásico era totalmente abierta (datos de acceso por defecto de Firebird).
- Un cajero con conocimientos técnicos limitados podía copiar la base de datos fácilmente y con cualquier cliente de Firebird ver o extraer cualquier información.
- Había terceros que realizaban integraciones (no autorizadas) conectándose directamente a la base de datos pudiendo causar discrepancia de la información, bugs, etc. sin darnos cuenta.
- Era fácil para la competencia crear herramientas para "migrar desde eleventa".
- Era fácil para la competencia/hackers ver el schema de la base de datos y conocer parte del funcionamiento interno del programa.

# Opciones evaluadas

1. Usar la librería nativa de SQLite que viene con el S.O. y manejar la encripción previo a INSERTS, UPDATES y SELECT por medio de rutinas de encripción y des encripción propias.
2. Usar SQLite compilado con la extensión SQLCipher para hacer la encripción de forma nativa y transpartente para la aplicación en todas sus plataformas.

# Decisión

Se opto por usar la libreria de SQLite con la extensión de SQLCipher usando el paquete [sqlcipher_flutter_libs](https://pub.dev/packages/sqlcipher_flutter_libs) para que usemos nuestra propia libreria de SQLite con encripción nativa en lugar de la que viene con los sistemas operativos (iOS, Android y macOS).

La librería de [sqlcipher_flutter_libs](https://pub.dev/packages/sqlcipher_flutter_libs) a diferencia de otras, soporta la creación de "user defined functions" en la que podemos exponer funciones propias hechas en Dart a los queries de SQL permitiendo funcionalidad a futuro.

Esta funcionalidad se implementó basándome en la guia de [Encryption Support de sqflite_common_ffi](https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/encryption_support.md)

# Consecuencias

- Para los usuarios puede haber un poco de "performance hit" por la encripción aunque en pruebas informales de rendimiento fue algo negligente, de acuerdo a reportes de internet el performance hit es del 10%.
- Los binarios crecerán un poco más debido a que ahora tenemos que incluir las librerías para cada plataforma propias.
- Las rutinas usadas por el servicio de sincronización tendrán que cambiarse/adaptarse para usar las rutinas de encripción y preferiblemente las mismas versiones (al momento de esta decisión se tienen la versiones SQLite v3.36.0, SQLCipher v4.5.0 community).
- Cada desarrollador tendrá que borrar lq base de datos de prueba que venía usando para que se re-cree pero ahora con soporte para encripción.
