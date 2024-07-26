import 'dart:io';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:install_referrer/install_referrer.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants.dart';

Future<Map<String, dynamic>> getDeviceData() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final List<ConnectivityResult> connectivityResult =
      await Connectivity().checkConnectivity();

  String? installReferrer;

  Map<String, dynamic> deviceData = {
    'application_name': packageInfo.appName,
    'build_number': packageInfo.buildNumber,
    'bundle_id': packageInfo.packageName,
    'connectivity': (connectivityResult.contains(ConnectivityResult.mobile))
        ? 'Mobile Network'
        : 'Wi-Fi',
    'version': packageInfo.version,
  };

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    deviceData.addAll({
      'android_id': androidInfo.id,
      'api_level': androidInfo.version.sdkInt,
      'base_os': androidInfo.version.baseOS,
      'build_id': androidInfo.id,
      'brand': androidInfo.brand,
      'device_id': androidInfo.id,
      'device_type': androidInfo.type,
      'device_name': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
    });

    try {
      final referrerDetails = await InstallReferrer.referrer;
      installReferrer = referrerDetails.toString();
    } catch (e) {
      developer.log(
        'Failed to get install referrer: ',
        error: e,
        name: packageName,
      );
    }
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    deviceData.addAll({
      'device_id': iosInfo.identifierForVendor,
      'device_name': iosInfo.name,
      'device_model': iosInfo.model,
      'system_name': iosInfo.systemName,
      'system_version': iosInfo.systemVersion,
    });
  }

  if (installReferrer != null) {
    deviceData['install_ref'] = installReferrer;
  }

  return deviceData;
}

// Future<Map<String, dynamic>> getDeviceData() async {
//   final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//   final PackageInfo packageInfo = await PackageInfo.fromPlatform();
//   final List<ConnectivityResult> connectivityResult =
//       await Connectivity().checkConnectivity();
//
//   Map<String, dynamic> deviceData = {
//     'application_name': packageInfo.appName,
//     'build_number': packageInfo.buildNumber,
//     'bundle_id': packageInfo.packageName,
//     'connectivity': (connectivityResult.contains(ConnectivityResult.mobile))
//         ? 'Mobile Network'
//         : 'Wi-Fi',
//     'version': packageInfo.version,
//     'system_version': SysInfo.kernelVersion,
//   };
//
//   String? userAgent;
//   String? installReferrer;
//
//   if (Platform.isAndroid) {
//     AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
//     userAgent =
//         'Mozilla/5.0 (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id}; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Mobile Safari/537.36';
//
//     deviceData.addAll({
//       'android_id': androidInfo.id,
//       'api_level': androidInfo.version.sdkInt,
//       'base_os': androidInfo.version.baseOS,
//       'build_id': androidInfo.id,
//       'brand': androidInfo.brand,
//       'device': androidInfo.device,
//       'device_id': androidInfo.id,
//       'device_type': androidInfo.type,
//       'device_name': androidInfo.model,
//       'manufacturer': androidInfo.manufacturer,
//     });
//
//     try {
//       final referrerDetails = await InstallReferrer.referrer;
//       installReferrer = referrerDetails.toString();
//     } catch (e) {
//       print('Failed to get install referrer: $e');
//     }
//   } else if (Platform.isIOS) {
//     IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
//     userAgent =
//         'Mozilla/5.0 (${iosInfo.utsname.machine}; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('.', '_')} like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/${iosInfo.model} Safari/604.1';
//
//     deviceData.addAll({
//       'device_name': iosInfo.name,
//       'device_model': iosInfo.model,
//       'system_name': iosInfo.systemName,
//       'system_version': iosInfo.systemVersion,
//       'device_id': iosInfo.identifierForVendor,
//     });
//
//     // Note: Install Referrer is not available on iOS
//   }
//
//   deviceData['user_agent'] = userAgent;
//   if (installReferrer != null) {
//     deviceData['install_ref'] = installReferrer;
//   }
//
//   print(deviceData);
//   return deviceData;
// }
