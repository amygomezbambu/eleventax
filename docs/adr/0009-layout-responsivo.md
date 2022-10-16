**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Uno de los objetivos del nuevo eleventa multiplataforma es la ejecución en dispositivos de distintas pantallas como celulares, tabletas y computadoras de escritorio. El lograr que la aplicación tenga soporte responsivo de acuerdo al tamaño de la pantalla del dispositivo es algo básico que usaremos en todos los módulos.

# Opciones evaluadas

- No usar ningun paquete y solo hacerlo por medio del soporte nativo de Flutter usando `MediaQuery.of`.
- Usar el (paquete `layout`)[https://pub.dev/packages/layout] para abstraer el manejo de esta lógica.
- Usar el (paquete `responsive_builder`)[https://pub.dev/packages/responsive_builder] para abstraer el manejo de esta lógica.

# Decisión

Se evaluó las tres opciones y aunque la simplicidad de basarnos solamente en el soporte de Flutter via MediaQuery es atractivo, tan pronto comenzamos a tener layouts un poco más complejos empieza a generar mucho código "boilerplate".

Entre los paquetes de `layout` y `responsive_builder`, el de layout ofreció un poco más simplicidad y menos lineas de código, asi como ser un poco más fácil de entender y ofrecer funciones auxiliares para ajustar la UI dependiendo de las dimensiones predefinidas de los dispositivos del mercado (usando los breakpoints definidos por la guia de Material Design de Google).

Con esta comparativa se eligió el paquete `layout` el cual cuenta con pruebas de unidad, mantenimiento constante y soporte para las versiones más recientes de Flutter.

# Consecuencias

Usar la lógica del paquete `Layout` cada vez que deseemos ajustar la UI dependiendo del tamaño de la pantalla de los dispositivos, principalmente por medio del siguiente código:

```dart

(context.breakpoint >= LayoutBreakpoint.sm) ?
    Text('Tablet o Desktop')
:
    Text('Celulares');

```
