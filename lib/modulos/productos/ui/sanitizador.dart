class SanitizadorProducto {
  static String codigo(String codigo) {
    return codigo.toUpperCase();
  }

  //TODO: mover a utils por si se usa en otros lados
  static String nombre(String nombre) {
    return nombre.trim().replaceAll(RegExp(' +'), ' ');
  }

  static String toTitleCase(String val) {
    var words = val.trim().toLowerCase().split(' ');
    for (var i = 0; i < words.length; i++) {
      if (words[i].length > 1 || i == 0) {
        words[i] =
            words[i].substring(0, 1).toUpperCase() + words[i].substring(1);
      }
    }

    return words.join(' ');
  }
}
