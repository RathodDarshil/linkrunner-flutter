import 'dart:io';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';

import '../constants.dart';

Future<Map<String, dynamic>> getDeviceData() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final List<ConnectivityResult> connectivityResult =
      await Connectivity().checkConnectivity();

  ReferrerDetails? androidInstallReferrer;

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
      androidInstallReferrer = await AndroidPlayInstallReferrer.installReferrer;
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

  if (androidInstallReferrer != null) {
    deviceData['install_ref_url'] = androidInstallReferrer.installReferrer;
    deviceData['install_ref_hashCode'] = androidInstallReferrer.hashCode;
    deviceData['install_ref_installBeginTimestampSeconds'] =
        androidInstallReferrer.installBeginTimestampSeconds;
    deviceData['install_ref_installBeginTimestampServerSeconds'] =
        androidInstallReferrer.installBeginTimestampServerSeconds;
    deviceData['install_ref_install_version'] =
        androidInstallReferrer.installVersion;
    deviceData['install_ref_referrerClickTimestampSeconds'] =
        androidInstallReferrer.referrerClickTimestampSeconds;
    deviceData['install_ref_referrerClickTimestampServerSeconds'] =
        androidInstallReferrer.referrerClickTimestampServerSeconds;
  }

  return deviceData;
}
