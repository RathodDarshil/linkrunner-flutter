import 'dart:io';

import 'package:carrier_info/carrier_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:install_referrer/install_referrer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:system_info2/system_info2.dart';

Future<Map<String, dynamic>> getDeviceData() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final List<ConnectivityResult> connectivityResult =
      await Connectivity().checkConnectivity();
  final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
  final AndroidCarrierData? androidCarrierData =
      await CarrierInfo.getAndroidInfo();
  final IosCarrierData iosCarrierData = await CarrierInfo.getIosInfo();

  String? userAgent;
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    userAgent =
        'Mozilla/5.0 (Linux; Android ${androidInfo.version.release}; ${androidInfo.model} Build/${androidInfo.id}; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Mobile Safari/537.36';
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
    userAgent =
        'Mozilla/5.0 (${iosInfo.utsname.machine}; CPU iPhone OS ${iosInfo.systemVersion.replaceAll('.', '_')} like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/${iosInfo.identifierForVendor}';
  }

  // Fetch install referrer
  String? installReferrer;
  try {
    final referrerDetails = await InstallReferrer.referrer;
    installReferrer = referrerDetails.toString();
  } catch (e) {}

  final deviceData = {
    'android_id': androidInfo.id,
    'api_level': androidInfo.version.sdkInt,
    'application_name': packageInfo.appName,
    'base_os': androidInfo.version.baseOS,
    'build_id': androidInfo.id,
    'brand': androidInfo.brand,
    'build_number': packageInfo.buildNumber,
    'bundle_id': packageInfo.packageName,
    'connectivity': (connectivityResult.contains(ConnectivityResult.mobile))
        ? 'Mobile Network'
        : 'Wi-Fi',
    'carrier': androidCarrierData?.telephonyInfo?.map((e) => e?.carrierName) ??
        iosCarrierData?.carrierData?.map((e) => e?.carrierName) ??
        [],
    'device': androidInfo.device,
    'device_id': androidInfo.id,
    'device_type': androidInfo.type,
    'device_name': androidInfo.model,
    'device_token': '', // Device token needs to be implemented separately
    'device_ip': '', // Device IP needs to be implemented separately
    'install_ref': installReferrer.toString(),
    'manufacturer': androidInfo.manufacturer,
    'user_agent': userAgent,
    'system_version': SysInfo.kernelVersion,
    'version': packageInfo.version,
  };

  return deviceData;
}
