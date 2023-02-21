**Status:** Aceptado
<br>
**Modulo Afectado:** Impresión

# Contexto
Para poder imprimir tickets en Windows se decidió hacerlo por medio de rutinas del API de Win32 de Windows para tener acceso a enviar comandos directamente a la impresora y poder acceder a rutinas de apertura de cajón, así como una impresión optimizada en velocidad al usar el estándard ESC/POS.

# Opciones evaluadas

1. Realizar la impresión por medio de [win32]<https://pub.dev/packages/win32> y las rutinas de impresión [documentadas por Windows]<https://learn.microsoft.com/en-us/windows/win32/printdocs/sending-data-directly-to-a-printer>.
2. Usar un paquete como [flutter_pos_printer_platform]<https://github.com/arthas1888/flutter_pos_printer_platform/>
3. Emular la impresión que hacemos en eleventa 5, la cual usa el modo gráfico (Canvas) por medio de la unidad `Vcl.Printers`.

# Decisión
Debido a que el mandar comandos directos (RAW) a la impresora nos permite tener un control total sobre la impresora de tickets y aprovechar los comandos ESC/POS para la apertura de cajón, así como rutinas de impresión directa y por tanto mucho más rapida se decidió comenzar con esta implementación.

# Consecuencias
Tendremos que buscar y encontrar una secuencia de comandos ESC/POS que sea "universalmente" soportado por la mayoria de las impresoras de nuestros usuarios.

# Referencias

* https://learn.microsoft.com/en-us/windows/win32/printdocs/sending-data-directly-to-a-printer
* https://groups.google.com/g/borland.public.delphi.objectpascal/c/hTQw6V12JvQ/m/zOmf8UbTClQJ
* [Ejemplo de impresion en Windows usando GDI]<https://www.equestionanswers.com/vcpp/screen-dc-printer-dc.php>
