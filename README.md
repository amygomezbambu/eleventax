# eleventa

El mejor punto de venta multi plataforma.

## Configurar ambiente de desarrollo

De momento el desarrollo de la aplicación se realiza principalmente en pair/mob programming sessions bajo MacOS. Para configurar tu computadora debes hacer lo siguiente:

1. Hacer el script ejecutable:
   `chmod +x ./tools/setup_new_mac.sh`

2. Ejecutar el script:
   `./tools/setup_new_mac.sh`

3. Algunas instalaciones requerirán tu contraseña

Posteriormente configura la extensión de Live Sharing accediendo a tu cuenta de GitHub:
https://docs.microsoft.com/en-us/visualstudio/liveshare/use/install-live-share-visual-studio-code#sign-in-to-live-share

## Pendientes para el MVP

- [x] Conectar la UI con el backend: ventas, productos.
- [x] Flujo CI/CD.
- [ ] Generar UI "final" y refactorizar.
- [ ] Enlazar productos + debug multiplataforma.

## Pendientes Arquitectura

- [ ] Definir esquema de migraciones, si basado en timestamp o version, etc.
- [ ] Decidir lenguaje Ubicuo?
- [ ] Decidir si nos vamos por UUID v4.
- [ ] Definir metodologia y/o paquete para manejo de estado (Riverpod).
- [ ] Definir Design System.

## Pendientes para entrar en flujo de trabajo "normal"

- [ ] Logeo.
- [ ] Transacciones.
- [ ] Publicar en tiendas versiones beta automaticamente.
- [ ] Internacionalización.
- [ ] Logeo de eventos / auditoria.

## Convenciones

## Definir flujo de trabajo

- [ ]
