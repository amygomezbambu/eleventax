import 'package:eleventa/modulos/common/ui/ex_icons.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/productos/dto/busqueda_producto_dto.dart';
import 'package:eleventa/modulos/productos/modulo_productos.dart';
import 'package:eleventa/modulos/ventas/ui/widgets/resultados_busqueda.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_trigger_autocomplete/multi_trigger_autocomplete.dart';

class CampoCodigoProducto extends StatefulWidget {
  final Function(String codigoProducto) onProductoElegido;
  final Function(FocusNode, RawKeyEvent) onKey;
  final TextEditingController textEditingController;
  final FocusNode focusNode;

  const CampoCodigoProducto(
      {Key? key,
      required this.onProductoElegido,
      required this.onKey,
      required this.textEditingController,
      required this.focusNode})
      : super(key: key);

  @override
  State<CampoCodigoProducto> createState() => _CampoCodigoProductoState();
}

class _CampoCodigoProductoState extends State<CampoCodigoProducto> {
  BusquedaProductoDto? _productoBuscadoSeleccionado;
  int? _indiceProductoSeleccionado;
  List<BusquedaProductoDto> _resultados = [];
  String _ultimaBusqueda = '';
  bool _buscando = false;
  bool _overlayMostrado = false;
  final _consultas = ModuloProductos.repositorioConsultaProductos();

  KeyEventResult _manejarTeclaPresionada(FocusNode node, RawKeyEvent keyEvent,
      BuildContext autocompleteContext, TextEditingController controller) {
    final autocomplete = MultiTriggerAutocomplete.of(autocompleteContext);

    // Si NO estamos mostrando el listado de búsqueda pasamos el evento
    // a los demás widgets para que lo manejen
    if (!_overlayMostrado) {
      var res = widget.onKey(node, keyEvent);
      return res;
    }

    if (keyEvent is RawKeyDownEvent) {
      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          // Si no hay indice seleccionado y presionamos tecla abajo
          // el seleccionado será el el primero de la lista
          _indiceProductoSeleccionado ??= -1;

          if (_indiceProductoSeleccionado != null) {
            if (_indiceProductoSeleccionado! < _resultados.length - 1) {
              _indiceProductoSeleccionado = _indiceProductoSeleccionado! + 1;
              _productoBuscadoSeleccionado =
                  _resultados.elementAt(_indiceProductoSeleccionado!);
            }
          }
        });

        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          // Si no hay indice seleccionado y presionamos tecla arriba
          // el seleccionado será el último de la lista
          _indiceProductoSeleccionado ??= _resultados.length;

          if (_indiceProductoSeleccionado != null) {
            if (_indiceProductoSeleccionado! > 0) {
              _indiceProductoSeleccionado = _indiceProductoSeleccionado! - 1;
              _productoBuscadoSeleccionado =
                  _resultados.elementAt(_indiceProductoSeleccionado!);
            }
          }
        });

        return KeyEventResult.handled;
      }

      if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
        // Si presionan ENTER pero no hubo producto seleccionado
        // entonces mandamos el texto ingresado "tal cual"
        if (_productoBuscadoSeleccionado == null) {
          widget.onProductoElegido(widget.textEditingController.text);
        } else {
          _indiceProductoSeleccionado = null;
          controller.clear();
          autocomplete.closeOptions();
          _overlayMostrado = false;

          widget.onProductoElegido(_productoBuscadoSeleccionado!.codigo);
        }

        return KeyEventResult.handled;
      }

      // Cancelamos la búsqueda y cerramos el overlay
      if (keyEvent.logicalKey == LogicalKeyboardKey.escape) {
        _indiceProductoSeleccionado = null;
        _overlayMostrado = false;
        final autocomplete = MultiTriggerAutocomplete.of(autocompleteContext);
        autocomplete.closeOptions();

        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  Future<List<BusquedaProductoDto>> _buscar(String query) async {
    if (_ultimaBusqueda == query) {
      return _resultados;
    }

    _ultimaBusqueda = query;
    _buscando = true;
    _indiceProductoSeleccionado = null;
    _productoBuscadoSeleccionado = null;

    return _consultas.buscarProductos(criterio: query);
  }

  @override
  Widget build(BuildContext context) {
    return MultiTriggerAutocomplete(
      optionsAlignment: OptionsAlignment.bottomStart,
      textEditingController: widget.textEditingController,
      focusNode: widget.focusNode,
      // TODO: Ver que valor optimo poner aqui
      //debounceDuration: const Duration(seconds: 2),
      autocompleteTriggers: [
        _AutocompleteSinTrigger(
          optionsViewBuilder: (context, autocompleteQuery, controller) {
            return FutureBuilder<List<BusquedaProductoDto>>(
              future: _buscar(autocompleteQuery.query),
              initialData: const [],
              builder: (BuildContext context,
                  AsyncSnapshot<List<BusquedaProductoDto>> snapshot) {
                if ((snapshot.hasData)) {
                  _overlayMostrado = true;
                  _resultados = snapshot.data!;
                  _buscando = false;

                  return ResultadosDeBusqueda(
                    query: autocompleteQuery.query,
                    selectedIndex: _indiceProductoSeleccionado,
                    resultados: snapshot.data!,
                    buscando: _buscando,
                    onProductoSeleccionado: (resultado) {
                      final autocomplete = MultiTriggerAutocomplete.of(context);

                      widget.onProductoElegido(resultado.codigo);
                      autocomplete.closeOptions();
                    },
                  );
                } else {
                  // Si no hay resultados aún no mandamos ningun widget
                  return const SizedBox();
                }
              },
            );
          },
        ),
      ],
      fieldViewBuilder: (context, controller, focusNode) {
        return Padding(
            padding: const EdgeInsets.all(0.0),
            child: Focus(
                onKey: (focusNode_, keyEvent_) {
                  return _manejarTeclaPresionada(
                      focusNode_, keyEvent_, context, controller);
                },
                focusNode: focusNode,
                child: TextField(
                  controller: controller,
                  cursorColor: Colors.black,
                  autocorrect: false,
                  autofocus: true,
                  style: const TextStyle(
                      color: ColoresBase.neutral700,
                      fontSize: DesignSystem.campoTamanoTexto,
                      fontWeight: FontWeight.normal),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(Sizes.p4),
                    helperStyle: const TextStyle(
                        fontSize: DesignSystem.campoTamanoTexto),
                    filled: true,
                    isDense: true,
                    fillColor: ColoresBase.white,
                    suffix: _buscando
                        ? const SizedBox(
                            width: 0,
                            height: 0,
                            child: CircularProgressIndicator(
                                strokeWidth: 3.0,
                                color: ColoresBase.primario700))
                        : null,
                    prefixIcon: const Icon(
                      Iconos.barcode,
                      color: ColoresBase.neutral300,
                    ),
                    hintText:
                        'Ingresa el código o parte del nombre del producto ',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.p0),
                      borderSide: const BorderSide(
                        color: ColoresBase.neutral300,
                        width: Sizes.px,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Sizes.p0),
                      borderSide: const BorderSide(
                        color: Colores.campoBordeEnfocado,
                        width: Sizes.px_5,
                      ),
                    ),
                  ),
                )));
      },
    );
  }
}

class _AutocompleteSinTrigger extends AutocompleteTrigger {
  DateTime? _lastTime;

  /// Crea un [AutocompleteTrigger] que no necesita de un caracter trigger
  /// siempre se lanza una vez pasado el tiempo de debounce
  _AutocompleteSinTrigger({
    required super.optionsViewBuilder,
  }) : super(trigger: '');

  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is AutocompleteTrigger &&
  //         runtimeType == other.runtimeType &&
  //         trigger == other.trigger &&
  //         triggerOnlyAtStart == other.triggerOnlyAtStart &&
  //         triggerOnlyAfterSpace == other.triggerOnlyAfterSpace &&
  //         minimumRequiredCharacters == other.minimumRequiredCharacters;

  // @override
  // int get hashCode =>
  //     trigger.hashCode ^
  //     triggerOnlyAtStart.hashCode ^
  //     triggerOnlyAfterSpace.hashCode ^
  //     minimumRequiredCharacters.hashCode;

  /// Checks if the user is invoking the recognising [trigger] and returns
  /// the autocomplete query if so.
  @override
  AutocompleteQuery? invokingTrigger(TextEditingValue textEditingValue) {
    final text = textEditingValue.text;

    // Checamos si ya pasó al menos el tiempo esperado
    _lastTime ??= DateTime.now();

    Duration elapsedTime = DateTime.now().difference(_lastTime!);

    if (text.length < minimumRequiredCharacters) return null;

    // TODO: Ver si es necesario este chequeo o siempre regresamos la lista
    if (elapsedTime.inMilliseconds >= 0) {
      return AutocompleteQuery(
        query: text,
        selection: const TextSelection(
          baseOffset: 0,
          extentOffset: 0,
        ),
      );
    } else {
      return null;
    }
  }
}
