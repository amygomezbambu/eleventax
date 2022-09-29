import 'dart:io';
import 'dart:ui';

import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:eleventa/modulos/common/app/interface/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eleventa/dependencias.dart';
import 'dart:async';

class AdaptadorDeDispositivo implements IAdaptadorDeDispositivo {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final ILogger _logger = Dependencias.infra.logger();

  // ignore: empty_constructor_bodies
  AdaptadorDeDispositivo() {}

  @override
  Future<InfoDispositivo> obtenerDatos() async {
    var infoDispositivo = InfoDispositivo();

    leerInfoComun(infoDispositivo);
    // if (Platform.isAndroid) {
    //   infoDispositivo =
    //       _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    // } else if (Platform.isIOS) {
    //   infoDispositivo = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    // } else if (Platform.isMacOS) {
    //   infoDispositivo = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
    // } else if (Platform.isWindows) {
    //   infoDispositivo =
    //       _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
    // }

    return infoDispositivo;
  }

  void leerInfoComun(InfoDispositivo info) {
    info.sistemaOperativo = Platform.operatingSystem;
    // Convertimos los pixeles fisicos a pixeles lógicos
    // para evitar tener discrepancias entre dispositivos retina vs no-retina.
    info.altoPantalla = window.physicalSize.height / window.devicePixelRatio;
    info.anchoPantalla = window.physicalSize.width / window.devicePixelRatio;
  }

  // InfoDispositivo _readAndroidBuildData(AndroidDeviceInfo build) {
  //   var info = InfoDispositivo();

  //   return info;
  // return <String, dynamic>{
  //   'version.securityPatch': build.version.securityPatch,
  //   'version.sdkInt': build.version.sdkInt,
  //   'version.release': build.version.release,
  //   'version.previewSdkInt': build.version.previewSdkInt,
  //   'version.incremental': build.version.incremental,
  //   'version.codename': build.version.codename,
  //   'version.baseOS': build.version.baseOS,
  //   'board': build.board,
  //   'bootloader': build.bootloader,
  //   'brand': build.brand,
  //   'device': build.device,
  //   'display': build.display,
  //   'fingerprint': build.fingerprint,
  //   'hardware': build.hardware,
  //   'host': build.host,
  //   'id': build.id,
  //   'manufacturer': build.manufacturer,
  //   'model': build.model,
  //   'product': build.product,
  //   'supported32BitAbis': build.supported32BitAbis,
  //   'supported64BitAbis': build.supported64BitAbis,
  //   'supportedAbis': build.supportedAbis,
  //   'tags': build.tags,
  //   'type': build.type,
  //   'isPhysicalDevice': build.isPhysicalDevice,
  //   'systemFeatures': build.systemFeatures,
  // };
  // }

  //Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
  //   return <String, dynamic>{
  //     'name': data.name,
  //     'systemName': data.systemName,
  //     'systemVersion': data.systemVersion,
  //     'model': data.model,
  //     'localizedModel': data.localizedModel,
  //     'identifierForVendor': data.identifierForVendor,
  //     'isPhysicalDevice': data.isPhysicalDevice,
  //     'utsname.sysname:': data.utsname.sysname,
  //     'utsname.nodename:': data.utsname.nodename,
  //     'utsname.release:': data.utsname.release,
  //     'utsname.version:': data.utsname.version,
  //     'utsname.machine:': data.utsname.machine,
  //   };
  // }

  // Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
  //   return <String, dynamic>{
  //     'computerName': data.computerName,
  //     'hostName': data.hostName,
  //     'arch': data.arch,
  //     'model': data.model,
  //     'kernelVersion': data.kernelVersion,
  //     'osRelease': data.osRelease,
  //     'activeCPUs': data.activeCPUs,
  //     'memorySize': data.memorySize,
  //     'cpuFrequency': data.cpuFrequency,
  //     'systemGUID': data.systemGUID,
  //   };
  // }

  // Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
  //   return <String, dynamic>{
  //     'numberOfCores': data.numberOfCores,
  //     'computerName': data.computerName,
  //     'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
  //   };
  // }
}
