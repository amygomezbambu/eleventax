**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Se evaluó cómo se llevará a cabo la configuración de la aplicación tanto local como compartida entre los distintos equipos del cliente de eleventa.

# Opciones evaluadas

- Utilizar una sola tabla en base de datos e ingresar los valores de configuración para cada módulo como strings.
- Utilizar una sola tabla en base de datos e ingresar los valores de configuración para cada módulo como json.
- Utilizar varias tablas, una por módulo e ingresar los valores de configuración como json

# Decisión

Se llevarán 3 tipos de configuración, la compartida, la local y la de aplicación. Para la configuración compartida se decidió utilizar una tabla en base de datos e ingresar los valores para cada módulo como un json. los datos sensibles como credenciales de recargas del usuario e información que NO DEBE SALIR del dispositivo se almacenará en la configuración local, los datos como credenciales, secrets, etc propios de eleventa (credenciales de sentry, APIs, etc) serán almacenados en la configuración de aplicación.

# Consecuencias

Ninguna
