**Status:** Aceptado
<br>
**Modulo Afectado:** Todos

# Contexto

Debe existir un estandar de decimales para evitar que en distintos lugares del sistema se usen diferente numero de decimales.


# Decisión

- Los catalogos, por ejemplo los productos, almacenaran en la DB 8 decimales en los campos necesarios para calculos, como el precio.
- Se almacenaran en DB como Integer.
- Los documentos redondearan los totales y se almacenaran con 2 decimales, al guardarse pasa a ser un hecho y no se debe
recalcular nunca, los totales del documento deben ser el resultado de la sumatoria de sus conceptos, por ejemplo:

Si una venta tiene 2 lineas de producto y en cada una de ellas el total de la linea se redondea, el total de la venta
debe ser la sumatoria de los totales de las lineas, lo incorrecto seria tomar los datos originales de las lineas y calcular
por separado los totales del documento ya que esto puede producir inconsistencias.

```
producto1 precio 100.46453653 cantidad 7 total 703.25
producto2 precio 90.48545685 cantidad 3 total 271.46

el total de la venta debe ser 703.25 + 271.46 y no sumar los precios y cantidades por linea y reondear al final,
es decir el redondeo se produce en los conceptos y nunca en los totales y debe ser siempre hacia arriba(ceil),
esto puedo producir inconsistencias si el usuario toma una calculadora y hace sus calculos, pero siempre le 
beneficiara ya que ganara centavos en cada redondeo y debe estar consiente que es necesario el redondeo ya 
que no es posible cobrar unidades de moneda menores al centavo, un cliente no puede pagarte 1 decimo de centavo.

En la practica la maxima ganacia por redondeo de cada linea es de 1 centavo a favor del usuario.
```

# Consecuencias