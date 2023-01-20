import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:eleventa/l10n/generated/l10n.dart';
import 'package:eleventa/modulos/common/ui/ex_mobile_scanner_overlay.dart';
import 'package:eleventa/modulos/common/ui/tema/theme.dart';
import 'package:eleventa/modulos/common/ui/widgets/ex_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path_provider/path_provider.dart';

/// Tamaño de la imagen que se envía al detector de códigos de barras
/// de acuerdo a la [guia de Google MLKit]<https://developers.google.com/ml-kit/vision/barcode-scanning/ios>
const tamanoImagen = 1024;

/// Cuadros por segundo que se envían al detector de códigos de barras
const cuadrosPorSegundo = 5.0;

/// Widget que muestra la vista previa de la cámara del dispositivo
/// con un overlay de ayuda visual para escanear códigos de barras
/// tan pronto detecta un código de barras se regresa a la navegación via
/// Navigator.pop(context, valorCodigodeBarras);
class ExMobileScanner extends StatefulWidget {
  const ExMobileScanner({super.key});

  @override
  State<ExMobileScanner> createState() => _ExMobileScannerState();
}

// TODO: Comenzar timer en cuanto se muestra la vista de la cámra
// y mandar un evento de TTS (time to scan) a Mixpanel
// para que se pueda medir el tiempo que tarda el usuario en escanear
// y si en el futuro cambiamos de librería tener datos para ver si mejoró o no esta métrica
class _ExMobileScannerState extends State<ExMobileScanner> {
  // Scanner de código de barras de Google MLKit
  // Omitimos la lecutura de codigos de 2 dimensiones: QR, Aztec, PDF417, ITF y otros
  // que usualmente no se usan en los códigos de barras de productos
  final _barcodeScanner = BarcodeScanner(formats: [
    BarcodeFormat.ean13,
    BarcodeFormat.ean8,
    BarcodeFormat.code128,
    BarcodeFormat.code39,
    BarcodeFormat.code93,
    BarcodeFormat.upca,
    BarcodeFormat.upce,
    BarcodeFormat.codabar
  ]);
  bool codigoEscaneado = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = L10n.of(context);

    return Scaffold(
      appBar: ExAppBar(
        title: Text(m.escaner_titulo,
            style: const TextStyle(
                color: Colors.white, fontSize: TextSizes.textLg)),
        centerTitle: true,
      ),
      body: CameraAwesomeBuilder.custom(
        initialCaptureMode: CaptureMode.photo,
        // No necesitamos audio
        enableAudio: false,
        saveConfig:
            SaveConfig.photo(pathBuilder: () => _path(CaptureMode.photo)),
        onImageForAnalysis: (img) => _processImageBarcode(img),
        imageAnalysisConfig: AnalysisConfig(
          outputFormat: InputAnalysisImageFormat.nv21,
          width: tamanoImagen,
          maxFramesPerSecond: cuadrosPorSegundo, //12
        ),
        builder: (cameraModeState, previewSize, previewRect) {
          return const ExMobileScannerOverlay(
            overlayColour: Colors.black45,
          );
        },
      ),
    );
  }

  /// Se encarga de procesar la imagen y hacer un análisis usando Google MLKit
  /// código tomado de: https://github.com/Apparence-io/CamerAwesome/blob/master/example/lib/ai_analysis_barcode.dart
  Future<void> _processImageBarcode(AnalysisImage img) async {
    final Size imageSize = Size(img.width.toDouble(), img.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotation.values.byName(img.rotation.name);

    final planeData = img.planes.map(
      (plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: img.height,
          width: img.width,
        );
      },
    ).toList();

    final InputImage inputImage;
    if (Platform.isIOS) {
      final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imageRotation,
        inputImageFormat: _inputImageFormat(img.format),
        planeData: planeData,
      );

      final WriteBuffer allBytes = WriteBuffer();
      for (final ImagePlane plane in img.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    } else {
      inputImage = InputImage.fromBytes(
        bytes: img.nv21Image!,
        inputImageData: InputImageData(
          imageRotation: imageRotation,
          inputImageFormat: InputImageFormat.nv21,
          planeData: planeData,
          size: Size(img.width.toDouble(), img.height.toDouble()),
        ),
      );
    }

    try {
      var recognizedBarCodes = await _barcodeScanner.processImage(inputImage);
      // Con todos los codigos de barras detectados...
      for (Barcode barcode in recognizedBarCodes) {
        //debugPrint("Barcode: [${barcode.format}]: ${barcode.rawValue}");

        if (!mounted) return;
        if (codigoEscaneado) return;

        // Al primer código de barras detectado regresamos de la navegación
        // con el resultado del código de barras obtenido
        // esto debido a que durante el análisis de la imagen se pueden detectar
        // varios códigos y/o varias veces el mismo código de barras
        if (Navigator.canPop(context)) {
          codigoEscaneado = true;
          // Regresamos el valor del barcode
          Navigator.pop(context, barcode.rawValue);
        }
      }
    } catch (error) {
      // TODO: Ver que tipo de error regresamos de acuerdo a nuestra arquitectura
      debugPrint("...sending image resulted error $error");
    }
  }

  Future<String> _path(CaptureMode captureMode) async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
        await Directory('${extDir.path}/eleventa-cbb').create(recursive: true);
    final String fileExtension =
        captureMode == CaptureMode.photo ? 'jpg' : 'mp4';
    final String filePath =
        '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    return filePath;
  }

  InputImageFormat _inputImageFormat(InputAnalysisImageFormat format) {
    switch (format) {
      case InputAnalysisImageFormat.bgra8888:
        return InputImageFormat.bgra8888;
      case InputAnalysisImageFormat.nv21:
        return InputImageFormat.nv21;
      default:
        return InputImageFormat.yuv420;
    }
  }
}
