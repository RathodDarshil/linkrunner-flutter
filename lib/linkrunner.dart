import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class LinkRunner {
  static const String baseUrl = 'https://api.linkrunner.io';
  static const String encryptedStorageTokenName = 'linkrunner-token';
  static const String packageVersion = '0.4.2';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceData() async {
    var deviceData = <String, dynamic>{};

    try {
      var deviceInfoData = await deviceInfo.deviceInfo;
      deviceData = deviceInfoData.toMap();
      deviceData['package_version'] = packageVersion;
      deviceData['version'] = deviceData['version']; // Assuming version is fetched here
    } catch (e) {
      print('Failed to get device info: $e');
    }

    return deviceData;
  }

  Future<void> init(String token) async {
    if (token.isEmpty) {
      print('Linkrunner needs your project token to initialize!');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/api/client/init'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'package_version': packageVersion,
          'app_version': (await getDeviceData())['version'],
          'device_data': await getDeviceData(),
        }),
      );

      var result = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await secureStorage.write(key: encryptedStorageTokenName, value: token);
        print('Linkrunner initialised successfully 🔥');
      } else {
        throw Exception(result['msg']);
      }
    } catch (e) {
      print('Error initializing Linkrunner: $e');
    }
  }

  Future<void> trigger(Map<String, dynamic> userData, Map<String, dynamic> data) async {
    String? token = await secureStorage.read(key: encryptedStorageTokenName);

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/api/client/trigger'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'user_data': userData,
          'data': {
            ...data,
            'device_data': await getDeviceData(),
          },
        }),
      );

      var result = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Linkrunner: Trigger called 🔥');
      } else {
        print('Linkrunner: Trigger failed');
        print('Linkrunner: ${result['msg']}');
      }
    } catch (e) {
      print('Linkrunner: Trigger failed');
      print('Linkrunner: $e');
    }
  }
}