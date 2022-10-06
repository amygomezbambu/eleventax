**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Al depender de distintos servicios externos como métricas o telemetría, requerimos incorporar credenciales de autenticación de estos servicios (Secretos). El mantener estos secretos fuera de control de versiones es una necesidad primordial de seguridad así como el evitar que estos secretos sean embebidos en el binario de forma directa.

# Opciones evaluadas

- Usar "dart-define" para incluir los secretos cada vez que se ejecute, prueben o construyan los binarios.
- Usar el paquete "envied" para automatizar la generación de secretos en base a un archivo de variables de entorno.

# Decisión

Debido a que, el incluir cada secreto como parámetro usando dart-define se puede volver complicado de mantener, asi como el no tener una manera fácil para los desarrolladores para incoporar los valores en la ejecución de las pruebas de unidad se optó por usar el paquete envied justo con la herramienta 1Password cli para automatizar la obtención de los secretos de la aplicación.

Las guias usadas para hacer esta configuración fueron:

1. Agregar y configurar paquete envied: https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/
2. Instalar y configurar 1Password cli: https://developer.1password.com/docs/cli/get-started/#install
3. Configurar app.env para que lea los valores de forma dinamica usando 1password cli: https://developer.1password.com/docs/cli/secrets-environment-variables#use-environment-env-files

# Consecuencias

Cada desarrollador debe tener instalado 1Password así como tener acceso vigente al vault de "Desarrollo" donde se encuentran los elementos de secretos de la aplicaicón. La convención usada es que todo secreto usado en el proyecto tiene el prefijo: "eleventax - XXXX".

Si se desea actualizar las variables de entorno locales existe el VSCode Task: "Refrescar secretos del entorno desde 1Password"
