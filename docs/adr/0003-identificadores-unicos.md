**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Necesitamos generar identificadores unicos para las entidades, esto con el fin de no depender
de identificadores auto-incrementales ya que eleventa es un sistema distribuido y es bien
conocido que en este tipo de sistemas los indetificadores auto-incrementales tienes varios problemas.

# Opciones evaluadas

- UUID v4
- UUID v7
- NanoID

# Decisión

Usaremos un paquete llamado [XID](https://pub.dev/packages/xid), seleccionamos este paquete debido a que tiene algunas ventajas sobre las otras opciones:

- es mas pequeño, por consecuencia ocupa menos especio al ser almacenado y menos ancho de banda al ser transmitido.
- es ordenable, aunque esto no es algo que nos ayude o afecte demasiado el ser ordenable
  puede sernos util en alguna ocasión.

# Consecuencias

Anteriormente usabamos el paquete [UUID](https://pub.dev/packages/uuid), por lo que tendremos que cambiar todos los lugares
en donde se este usando el paquete anterior.
