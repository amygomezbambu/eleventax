import 'package:any_base/any_base.dart';
import 'package:murmurhash/murmurhash.dart';

class Node {
  var acumulatedValue = '';

  late int _value;
  late int _hash;
  Node? _parent;
  final _children = <Node>[];

  int get value => _value;
  int get hash => _hash;
  List<Node> get children => List.unmodifiable(_children);

  Node({required int value, Node? parent}) {
    _value = value;
    _parent = parent;

    acumulatedValue = value.toString();
  }

  Node addChild(int value, int? hash) {
    var node = Node(value: value, parent: this);
    node.acumulatedValue = acumulatedValue + value.toString();

    if (hash != null) node._hash = hash;

    if (_children.where((child) => child.value == value).isEmpty) {
      _children.add(node);

      return node;
    } else {
      return _children.singleWhere((child) => child.value == value);
    }
  }

  Node getChildren(int value) {
    return _children.singleWhere((node) => node.value == value);
  }

  String serialize({isRoot = false}) {
    var result = '';

    if (isRoot) {
      result = '${value.toString()}:${hash.toString()}:';
    }

    if (_children.isNotEmpty) {
      _children.sort((first, second) => first.value.compareTo(second.value));

      final childCount = _children.length;

      for (var i = 0; i < 3; i++) {
        if (i >= childCount) {
          result += '|-1:';
        } else {
          var child = _children[i];

          result += '|${child.value.toString()}:${child.hash.toString()}:';

          if (child.children.isNotEmpty) {
            result += child.serialize();
          } else {
            result += 'L';
          }
        }
      }
    }

    return result;
  }

  void calculateHash() {
    var stringToHash = '';

    for (var child in _children) {
      stringToHash += child.hash.toString();
    }

    stringToHash += value.toString();

    // final bytes = utf8.encode(stringToHash);

    // _hash = xxh3(Uint8List.fromList(bytes), seed: 0x0);

    _hash = MurmurHash.v3(stringToHash, 12345);

    _parent?.calculateHash();
  }
}

class Merkle {
  Node? tree;

  late Node currentNode;
  late int globalIndex;
  late List<String> values;

  /// Agrega un timestamp al arbol
  ///
  /// el timestamp debe ser un unix epoch en milisegundos
  void addTimeStamp(int timestamp) {
    //convertirlo a minutos
    timestamp = (timestamp / 1000) ~/ 60;

    //convertirlo a base3
    const base3Alpha = '012';
    const base3Converter = AnyBase(AnyBase.dec, base3Alpha);

    var base3Timestamp = base3Converter.convert(timestamp.toString());

    //debugPrint(base3Timestamp);

    //convertir cada caracter en un nodo
    var chars = base3Timestamp.split('');

    Node? currentNode;
    var level = 1;

    for (var char in chars) {
      if (level == 1) {
        tree ??= Node(value: int.parse(chars[0]));
        currentNode = tree;
      } else {
        currentNode = currentNode?.addChild(int.parse(char), null);
      }

      //Los timestamp en base3 tienen 16 digitos, si estamos en el ultimo digito
      //sabemos que terminamos
      if (level == 16) {
        currentNode?.calculateHash();
      }

      level++;
    }
  }

  /// Compara 2 arboles
  ///
  /// Regresa el timestamp a partir de donde los 2 arboles difieren.
  /// Si son iguales regresa una cadena vacia
  String compare(Node one, Node two, {bool isRoot = true}) {
    String result = '';
    //si son iguales y estamos en el root regresar inmediatamente
    if (isRoot && (one.hash == two.hash)) {
      return '';
    }

    //todo: agregar metodo sort a clase node
    one._children.sort((first, second) => first.value.compareTo(second.value));
    two._children.sort((first, second) => first.value.compareTo(second.value));

    final childCount = one.children.length;

    for (var i = 0; i < childCount; i++) {
      if (result.isNotEmpty) {
        break;
      }

      var child = one.children[i];

      var child2 =
          two.children.where((node) => node.value == child.value).toList();

      if (child2.isNotEmpty) {
        if (child.hash == child2[0].hash) {
          continue;
        } else {
          result = compare(child, child2[0], isRoot: false);
        }
      } else {
        //si el segundo arbol no tiene el nodo quiere decir que a partir de este
        //momento no tiene los eventos mas nuevos, puede ser que tenga algunos pero
        //decidimos que debemos enviar todos los elementes a partir de este momento
        return child.acumulatedValue;
      }
    }

    return result;
  }

  bool findTimeStamp(int timestamp) {
    //convertirlo a minutos
    timestamp = (timestamp / 1000) ~/ 60;

    //convertirlo a base3
    const base3Alpha = '012';
    const base3Converter = AnyBase(AnyBase.dec, base3Alpha);

    var base3Timestamp = base3Converter.convert(timestamp.toString());

    //convertir cada caracter en un nodo
    var chars = base3Timestamp.split('');
    var currentNode = tree!;
    var found = false;
    var isRoot = true;

    for (var char in chars) {
      //si estoy al final del arbol ya no tengo porque seguir
      if (currentNode.children.isEmpty) {
        break;
      }

      found = false;

      //si estoy en la raiz comparar su valor con el del primer caracter
      if (isRoot) {
        if (currentNode.value == int.parse(char)) {
          found = true;
          isRoot = false;
          continue;
        } else {
          break;
        }
      }

      //si no estoy en la raiz entonces buscar el cracter en los hijos
      for (var child in currentNode.children) {
        if (child.value == int.parse(char)) {
          found = true;
          currentNode = child;
          break;
        }
      }
    }

    return found;
  }

  String serialize() {
    if (tree == null) {
      throw Exception('El arbol esta vacío');
    }

    return tree!.serialize(isRoot: true);
  }

  void deserialize(String serializedTrie) {
    var nodes = serializedTrie.split("|");
    var parts = nodes[0].split(":");
    var value = parts[0];
    var hash = parts[1];

    tree = Node(value: int.parse(value));
    tree!._hash = int.parse(hash);

    nodes.removeAt(0);

    globalIndex = 0;
    currentNode = tree!;
    values = nodes;

    buildTrie();
  }

  void buildTrie() {
    for (var index = 0; index < 3; index++) {
      var parts = values[globalIndex].split(":");
      var value = int.parse(parts[0]);
      late int hash;
      String type = "";

      if (parts.length == 3) {
        type = parts[2];
      }

      if (parts[1] != "") {
        hash = int.parse(parts[1]);
      }

      globalIndex++;

      if (value == -1) {
        if ((index == 2) && (currentNode._parent != null)) {
          currentNode = currentNode._parent!;
        }

        continue;
      }

      if (type == "L") {
        currentNode.addChild(value, hash);

        if (index == 2) {
          currentNode = currentNode._parent!;
        }
      } else {
        currentNode = currentNode.addChild(value, hash);
        buildTrie();
      }
    }
  }
}
