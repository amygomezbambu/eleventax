**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

# Opciones evaluadas

X

# Decisión

Se opto por usar (sqlite3)[https://github.com/simolus3/sqlite3.dart] debido a que muestra un mejor performance respecto a YY, además de que es una sola dependencia en lugar de 3. Adicionalmente se eligió usar la libreriía de SQLite con encripción (SQLCipher) para cumplir los siguientes motivos:

- Evitar que terceros no autorizados, en cualquier plataforma, pero principalmente en Windows accedan a la base de datos y alteren la información, el schema o extraigan ciertos datos que pueden ser propiedad intelectual de la empresa (como productos precargados).
- Mantener la privacidad de la información de los usuarios de eleventa por si un usuario mal intencionado llega a llevarse el archivo de base de datos no pueda extraer información del comercio que usa eleventa.

Adicionalmente la libreria XX soporta la creación de "user defined funcitions" en la que podemos exponer funciones custom hechas en Dart a los queries de SQL permitiendo funcionalidad a futuro.

https://github.com/tekartik/sqflite/blob/master/sqflite_common_ffi/doc/encryption_support.md

# Consecuencias

Se tendrán que modificar los métodos implementados de la clase que loguea en eleventax por los métodos y funciones que tiene la librería.
