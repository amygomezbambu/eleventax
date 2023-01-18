**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

En eleventa necesitamos almacenar en la base de datos las fechas/horas de distintos eventos como fechas de creación, cobro, etc.
Estas fechas/horas necesitan tomar en cuenta la zona horaria del dispositivo del usuario y considerar cambios de horarios, etc.

# Opciones evaluadas

1. Guardar la fecha/hora como cadenas ISO8601 ("YYYY-MM-DD HH:MM:SS.SSSZ").
2. Guardar la fecha/hora como UNIX epoc, milisegundos desde 1970-01-01 00:00:00 UTC.

# Decisión

Se almacenarán las fechas/horas (timestamps) como UNIX epoc por que al ser INT es más eficiente para la base de datos el ordenarlo, guardarlo y buscarlo. Al usar UNIX epoc garantizamos que siempre usemos fechas/horas en UTC.

# Consecuencias

Tener la convención de siempre guardar y leer en los repositorios usando UNIX epoc, con las funciones de Dart:

```dart
final dbValue = entidad.fecha.millisecondsSinceEpoch;
```

Y al leer de base de datos:

```dart
final fecha = DateTime.fromMillisecondsSinceEpoch(row['fecha'] as int);
```

De igual manera si se necesita realizar queries que retoren una fecha/hora legible para humanos, debemos usar las funciones de conversión de SQLite: <https://www.sqlite.org/lang_datefunc.html>

```SQL
SELECT datetime('creado_en', 'unixepoch', 'localtime') FROM ventas;
```

# Referencias
