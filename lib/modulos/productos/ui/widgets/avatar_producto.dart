import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:flutter/material.dart';

class AvatarProducto extends StatelessWidget {
  final String uniqueId;
  final String productName;

  const AvatarProducto(
      {super.key, required this.productName, required this.uniqueId});

  @override
  Widget build(BuildContext context) {
    String initials = productName.length > 1
        ? "${productName[0]}${productName[1]}"
        : productName[0];

    return ClipRRect(
      borderRadius: BorderRadius.circular(Sizes.p2),
      child: Container(
        color: getColorFromString(uniqueId),
        width: Sizes.p12,
        height: Sizes.p12,
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Obtiene un color en base a una cadena de texto
  ///ejem. 'ac170002-7446-1152-8174-46096d7f0000' -> Color(0xFFE91E63)
  Color getColorFromString(String radix16String) {
    Color hexColor = Colors.blue;
    try {
      hexColor = Color(StringToHex.toColor(radix16String));
    } catch (e) {
      //print('$radix16String is not a valid radix string');
    }
    return hexColor;
  }
}

/// A powerful conversion of [String] or/and Hash to HEX.
/// It returns a unique HEX, or a unique int of [Color()] per provided String/hash.
/// It's provided two methods [toHexString] and [toColor], which return a Hex-String, or respectively.
class StringToHex {
  /// This class get RGB Color
  /// by doing bits shifts from color [0xFF0000], [0x00FF00], [0x0000FF]
  static int _getInt(str) {
    var hash = 5381;

    for (var i = 0; i < str.length; i++) {
      hash = ((hash << 4) + hash) + str.codeUnitAt(i) as int;
    }

    return hash;
  }

  /// Return a [String] of 'bit hex':
  /// Its return is proper to your custom manipulating (as you lik better 🧑‍💻).
  /// Returns a String HEX with prefix '0xFF'
  /// i.e: '0xFF343434'
  static String toHexString(str) {
    try {
      var hash = _getInt(str);
      var r = (hash & 0xFF0000) >> 16;
      var g = (hash & 0x00FF00) >> 8;
      var b = hash & 0x0000FF;

      var rr = '0$r';
      var gg = '0$g';
      var bb = '0$b';

      return '0xFF${rr.substring(rr.length - 2)}${gg.substring(gg.length - 2)}${bb.substring(bb.length - 2)}';
    } catch (err) {
      debugPrint('Error: String Must be greater than range 2\n'
          '=========== hash string to hex ===========\n'
          '            string length = ${str.length}');
      return err.toString();
    }
  }

  /// Return a [int] of 'bit hex':
  /// Its return is proper to use as hex [color int] in a Color()
  /// For example: ``` ... color: Color(StringToHex().toColor('a nice String')) ... ```
  /// then it'll generate and fill a hex-color int in it.
  /// return a hex-color.
  /// i.e: 0xFF353535
  /// or: 8787451701
  static int toColor(str) {
    return int.parse(toHexString(str));
  }
}

// Image.network(
//   'https://source.unsplash.com/random/200×200/?${articulos[index].descripcion}',
//   // Le indicamos que que tamaño será la imagen para que consuma
//   // menos memoria aunque la imagen original sea más grande
//   cacheHeight: 50,
//   cacheWidth: 50,
//   fit: BoxFit.cover,
// )
