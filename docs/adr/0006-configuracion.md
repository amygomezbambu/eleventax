**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Se evaluó cómo se llevará a cabo la configuración de la aplicación tanto local como compartida entre los distintos equipos del cliente de eleventa.

# Opciones evaluadas

- Utilizar una sola tabla en base de datos e ingresar los valores de configuración para cada módulo como strings.
- Utilizar una sola tabla en base de datos e ingresar los valores de configuración para cada módulo como json.
- Utilizar varias tablas, una por módulo e ingresar los valores de configuración como json.
- Utilizar varias tablas, una por módulo e ingresar los valores de configuración como campos.

# Decisión

Se llevarán 3 tipos de configuración, la compartida, la local y la de aplicación:

- Para la configuración compartida se decidió utilizar una tabla por cada modulo en base de datos e ingresar los valores para cada módulo como campos. 

```sql
create table sales_config(
    uid text ,
    allowQuickItem bool null,
    allowZeroCost bool null
)
```
- Para la Configuración Local como preferencias personales por dispositivo, datos sensibles como credenciales de recargas del usuario e información que NO DEBE SALIR del dispositivo se almacenará en un archivo en el dispositivo local usando el paquete (shared_preferences)[https://pub.dev/packages/shared_preferences].
- La configuración de aplicación como credenciales, secrets, etc propios de eleventa (credenciales de sentry, APIs, etc) serán ingresados en el archivo config.dart cuyos valores serán modificados para el ambiente de producción por el servicio de CI.

Las rutas donde se guarda la configuración local son las siguientes:

- _Android_ -> SharedPreferences
- _iOS_ -> NSUserDefaults
- _Linux_ -> Directorio XDG_DATA_HOME
- _macOS_ -> NSUserDefaults
- _Windows_ -> Directorio Roaming AppData

# Consecuencias

Ninguna
