**Status:** Aceptado
<br>
**Modulo Afectado:** Productos

# Contexto

Si el usuario introduce el precio sin impuestos el resultado puede ser un precio con muchos decimales que seran visibles,
en las ventas y sus impresiones.

# Decisión

Forzaremos el precio neto a 2 decimales, si el calculo da un numero mayor de decimales se redondeará y se ajustara el precio
sin impuestos.

# Consecuencias
