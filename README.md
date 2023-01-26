# eleventa

El mejor punto de venta multi plataforma.

### Requisitos Mínimos

* macOS 10.4 (Mojave)
* Windows 7 (64 bits)
* iOS 12
* Android Lollipop (API 21)

## Configurar ambiente de desarrollo

De momento el desarrollo de la aplicación se realiza principalmente en pair/mob programming sessions bajo MacOS. Para configurar tu computadora debes hacer lo siguiente:

1. Hacer el script ejecutable:
   `chmod +x ./tools/setup_new_mac.sh`

2. Ejecutar el script:
   `./tools/setup_new_mac.sh`

3. Algunas instalaciones requerirán tu contraseña

Posteriormente configura la extensión de Live Sharing accediendo a tu cuenta de GitHub:
<https://docs.microsoft.com/en-us/visualstudio/liveshare/use/install-live-share-visual-studio-code#sign-in-to-live-share>

## Pruebas

Para probar la aplicación debes ejecutar:

Pruebas de Unidad:

```shell
flutter test
```

Pruebas de Integracióm:

```shell
flutter test integration_test
```

Pruebas de Integración en Google FireBase TestLab:

```shell
zsh tools\\probar_en_testlab.sh
```

## Manejo de versionamiento

Para agregar una nueva mejora al [CHANGELOG.md](/CHANGELOG.md) ejecutar en la terminal el comando `cider log` con las siguientes categorías:

* `added` - Funcionalidad nueva
* `changed`- Funcionalidad que cambió o se actualizó
* `deprecated` - Funcionalidad que pronto dejará de operar y se recomienda dejar de usar.
* `removed` - Funcionalidad que fue removida.
* `fixed` - Corrección de bug.
* `security`- Aspecto de seguridad corregido y de alta importancia.

Ejemplo:

```bash
cider log added "Se agrega una nueva funcionalidad"
```
