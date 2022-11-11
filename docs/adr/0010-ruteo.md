**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Cualquier aplicación requiere de navegación entre distintas vistas o pantallas. En Web y Flutter a este concepto se le llama "ruteo" (routing) y existen múltiples opciones para hacerlo posible en Flutter ya que existen distintos niveles de complejidad, incluyendo el soporte para "deep linking" o navegación directa a vistas dentro de una app por medio de URLs, especialmente útil en aplicaciones móviles.

# Opciones evaluadas

- No usar ningun paquete y solo hacerlo por medio del soporte nativo de Flutter usando (Navigator)[https://docs.flutter.dev/development/ui/navigation].
- Usar (paquete `go_router`)[https://pub.dev/packages/go_router]

# Decisión

Se estudió un poco el hacerlo por medio del soporte nativo de Flutter, sin embargo (la misma documentación de Flutter)[https://docs.flutter.dev/development/ui/navigation] recomienda este approach para aplicaciones sencillas solamente:

> Flutter provides a complete system for navigating between screens and handling deep links. Small applications without complex deep linking can use Navigator, while apps with specific deep linking and navigation requirements should also use the Router to correctly handle deep links on Android and iOS...

Sabiendo que eleventa será una aplicación compleja no tiene mucho caso empezar con navegación simple y refactorizar posteriormente cuando tengamos necesidades de navegación más compleja.

Se decidió usar el paquete `go_router` al ser un paquete creado por el equipo de Flutter directamente y ser de los más maduros, documentados y con artículos y lecciones de por medio.

# Consecuencias

Apegarse a la sintaxis y uso de navegación de GoRouter para cambiar entre vistas, diálogos, etc. usando las Dart extensions del paquete. Ejemplo:

```dart
onTap: () => context.goNamed(Rutas.ventas.name);
```
