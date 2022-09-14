**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Al modificar documentos se produce el riesgo de introducir inconsistencias en el sistema, un documento es por ejemplo:

- venta
- factura
- abono
- compra

# Opciones evaluadas

- Permitir que un documento sea modificado
- Impedir que los documentos puedan ser modificados.


# Decisión

Se decidió que un documento debe ser inmutable, es decir que una vez generado nunca puede cambiar, lo que se debe hacer
es generar otro documento que modifique el estado de la aplicacion de la manera deseada, por ejemplo una devolución a una
venta no modifica la venta, se genera un documento nuevo llamado devolución que hace referencia a la venta.

# Consecuencias
