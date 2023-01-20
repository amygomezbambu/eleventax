**Status:** Aceptado
<br>
**Modulo Afectado:** Ventas, Productos, Inventarios

# Contexto

eleventa en dispositivos móviles que tienen cámara integrada puede hacer uso de dicho hardware para la lectura de códigos de barra y por tanto ser más util y eficiente en la captura del catálogo de productos, ventas, entre otros.

Adicionalmente cualquier paquete que usemos para integrar con la cámara será útil para la toma de fotografías y/o video asociados con productos u otros catálogos.

# Opciones evaluadas

1. Paquete [flutter_barcode_scanner]<https://pub.dev/packages/flutter_barcode_scanner>.
2. Paquete [mobile_scanner]<https://pub.dev/packages/mobile_scanner> / [Google MLKit]<https://pub.dev/packages/google_mlkit_barcode_scanning>
3. Paquete [CamerAwesome] / [Google MLKit]<https://pub.dev/packages/google_mlkit_barcode_scanning>.

# Decisión

Los primeros dos paquetes si bien cuentan con bastante popularidad, parecen estar abandonados y/o depender de un solo desarrollador.

El tercer paquete llamado [CamerAwesome]<https://github.com/Apparence-io/CamerAwesome> permite usar la cámara del dispositivo para tomar fotos, video y opcionalmente realizar un análisis de la imagen para funcionamiento adicional (detección de códigos de barra, caras, etc.) esto usando internamente la dependencia de [Google MLKit]<https://pub.dev/packages/google_mlkit_barcode_scanning>.

Además de cumplir con los requisitos de funcionalidad, se eligió CamerAwesome debido a que es un paquete patrocinado por una empresa privada en Francia y no solo un desarrollador independiente, cuenta con actualizaciones constantes y recientes, y permite una lectura de códigos de barra usando la subdependencia de Google MLKit con un rendimiento adecuado.

Las ventajas de usar Google MLKit para la detección de los códigos de barra:

* Soporta los distintos formatos lineales: Codabar, Code 39, Code 93, Code 128, EAN-8, EAN-13, ITF, UPC-A, UPC-E y de 2D: Aztec, Data Matrix, PDF417, QR Code
* Funciona con cualquier orientación de la cámara.
* La decodificación se hace en el dispositivo, es decir funciona offline.
* Es gratuito :).

# Consecuencias

Apegarnos a usar un solo paquete/dependencia para el uso de cámaras bajo dispositivos móviles.

# Referencias

* Detección de códigos de barras usando Google MLKit: <https://developers.google.com/ml-kit/vision/barcode-scanning>
