**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Uno de los objetivos del nuevo eleventa multiplataforma es la ejecución en dispositivos de distintas pantallas como celulares, tabletas y computadoras de escritorio. El lograr que la aplicación tenga soporte responsivo de acuerdo al tamaño de la pantalla del dispositivo es algo básico.

# Opciones evaluadas

- No usar ningun paquete y solo hacerlo por medio del soporte nativo de Flutter usando `MediaQuery.of`.
- Usar el (paquete `layout`)[https://pub.dev/packages/layout] para abstraer el manejo de esta lógica.
- Usar el (paquete `responsive`)[https://pub.dev/packages/responsive_framework] para abstraer el manejo de esta lógica.

# Decisión

Aunque el manejar la lógica de responsividad puede ser algo que hagamos nosotros internamente, dependemos de que estamos siempre actualizados de las dimensiones de cada nuevo dispositivo del mercado sobre todo de dispositivos celulares y tablet en el que el panorama suele cambiar cada año o par de años así como.

Aunque se evaluó ambos paquetes, layout y responsive_builder se eligió XX debido a que:

-

# Consecuencias
