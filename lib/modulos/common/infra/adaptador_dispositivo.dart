import 'dart:io';
import 'dart:ui';

import 'package:eleventa/modulos/common/app/interface/dispositivo.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:eleventa/modulos/common/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class AdaptadorDeDispositivo implements IAdaptadorDeDispositivo {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  /* #region Singleton */
  static final instance = AdaptadorDeDispositivo._();

  AdaptadorDeDispositivo._();
  /* #endregion */

  @override
  Future<InfoDispositivo> obtenerDatos() async {
    var infoDispositivo = InfoDispositivo();

    if (Platform.isAndroid) {
      infoDispositivo = _leerAndroidInfo(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      infoDispositivo = _leerIOSInfo(await deviceInfoPlugin.iosInfo);
    } else if (Platform.isMacOS) {
      infoDispositivo = _leerMacInfo(await deviceInfoPlugin.macOsInfo);
    } else if (Platform.isWindows) {
      infoDispositivo = _leerWindowsInfo(await deviceInfoPlugin.windowsInfo);
    }

    await _leerInfoComun(infoDispositivo);

    return infoDispositivo;
  }

  Future<void> _leerInfoComun(InfoDispositivo info) async {
    var packageInfo = await PackageInfo.fromPlatform();

    info.so = Platform.operatingSystem;
    info.versionSO = Platform.operatingSystemVersion;

    // Obtenemos el numero de veces que se ha abierto leyendo
    // desde la configuración
    var prefs = await SharedPreferences.getInstance();
    info.numeroDeEjecuciones = prefs.getInt('numero_ejecuciones') ?? 0;
    info.numeroDeEjecuciones++;
    await prefs.setInt('numero_ejecuciones', info.numeroDeEjecuciones);

    // Convertimos los pixeles fisicos a pixeles lógicos
    // para evitar tener discrepanscias entre dispositivos retina vs no-retina.
    info.altoPantalla = window.physicalSize.height / window.devicePixelRatio;
    info.anchoPantalla = window.physicalSize.width / window.devicePixelRatio;
    info.lenguajeConfigurado = window.locale.languageCode;

    info.pais = window.locale.countryCode ?? '';

    // Diferencia entre hora local y UTC (Ejem: Chihuahua -> -6)
    info.zonaHoraria = DateTime.now().timeZoneOffset.inHours;

    //Informacion del Build
    info.appBuild = packageInfo.buildNumber;
    info.appVersion = packageInfo.version;

    info.ip = await Utils.red.obtenerIPPublica();
  }

  InfoDispositivo _leerAndroidInfo(AndroidDeviceInfo build) {
    var info = InfoDispositivo();

    info.modelo = build.model ?? '';
    info.fabricante = build.manufacturer ?? '';
    info.nombre = build.device ?? '';

    return info;
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
  }

  InfoDispositivo _leerIOSInfo(IosDeviceInfo data) {
    var info = InfoDispositivo();

    info.modelo = data.model ?? '';
    info.fabricante = 'Apple';
    info.nombre = data.name ?? '';

    return info;

    // return <String, dynamic>{
    //   'name': data.name,
    //   'systemName': data.systemName,
    //   'systemVersion': data.systemVersion,
    //   'model': data.model,
    //   'localizedModel': data.localizedModel,
    //   'identifierForVendor': data.identifierForVendor,
    //   'isPhysicalDevice': data.isPhysicalDevice,
    //   'utsname.sysname:': data.utsname.sysname,
    //   'utsname.nodename:': data.utsname.nodename,
    //   'utsname.release:': data.utsname.release,
    //   'utsname.version:': data.utsname.version,
    //   'utsname.machine:': data.utsname.machine,
    // };
  }

  InfoDispositivo _leerMacInfo(MacOsDeviceInfo data) {
    var info = InfoDispositivo();

    info.modelo = data.model;
    info.fabricante = 'Apple';
    info.nombre = data.computerName;

    return info;

    // return <String, dynamic>{
    //   'computerName': data.computerName,
    //   'hostName': data.hostName,
    //   'arch': data.arch,
    //   'model': data.model,
    //   'kernelVersion': data.kernelVersion,
    //   'osRelease': data.osRelease,
    //   'activeCPUs': data.activeCPUs,
    //   'memorySize': data.memorySize,
    //   'cpuFrequency': data.cpuFrequency,
    //   'systemGUID': data.systemGUID,
    // };
  }

  InfoDispositivo _leerWindowsInfo(WindowsDeviceInfo data) {
    var info = InfoDispositivo();

    info.modelo = '';
    info.fabricante = '';
    info.nombre = '';

    return info;

    // return <String, dynamic>{
    //   'numberOfCores': data.numberOfCores,
    //   'computerName': data.computerName,
    //   'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    // };
  }
}
