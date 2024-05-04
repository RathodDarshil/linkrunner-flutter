import 'dart:developer' as developer;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

const packageName = "linkrunner";

class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;

  LRUserData(
      {required this.id,
      required this.name,
      required this.phone,
      required this.email});

  Map<String, String?> toJSON() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}

class LinkRunner {
  static const String baseUrl = 'https://api.linkrunner.io';
  static const String encryptedStorageTokenKeyName = 'linkrunner-token';
  static const String packageVersion = '0.4.2';

  static const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, dynamic>> getDeviceData() async {
    var deviceData = <String, dynamic>{};

    try {
      var deviceInfoData = await deviceInfo.deviceInfo;
      deviceData = deviceInfoData.toMap();
      deviceData['package_version'] = packageVersion;
      deviceData['version'] =
          deviceData['version']; // Assuming version is fetched here
    } catch (e) {
      developer.log('Failed to get device info', error: e, name: packageName);
    }

    return deviceData;
  }

  static Future<void> init(String token) async {
    if (token.isEmpty) {
      developer.log(
        'Linkrunner needs your project token to initialize!',
        name: packageName,
      );
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
        await secureStorage.write(
            key: encryptedStorageTokenKeyName, value: token);
        developer.log('Linkrunner initialised successfully 🔥',
            name: packageName);
      } else {
        throw Exception(result['msg']);
      }
    } catch (e) {
      developer.log('Error initializing Linkrunner',
          error: e, name: packageName);
    }
  }

  static Future<void> trigger({
    required LRUserData userData,
    Map<String, dynamic>? data,
  }) async {
    String? token = await secureStorage.read(key: encryptedStorageTokenKeyName);

    if (token == null) {
      developer.log(
        'Token not found',
        name: packageName,
        error: Exception("linkrunner token not found"),
      );
      return;
    }

    final body = jsonEncode({
      'token': token,
      'user_data': userData.toJSON(),
      'data': {
        ...?data,
        'device_data': await getDeviceData(),
      },
    });

    try {
      var response = await http.post(
        Uri.parse('$baseUrl/api/client/trigger'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      var result = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log(
          'Linkrunner: Trigger called 🔥',
          name: packageName,
        );
      } else {
        developer.log(
          'Linkrunner: Trigger failed',
          name: packageName,
          error: jsonEncode(result['msg']),
        );
      }
    } catch (e) {
      developer.log(
        'Linkrunner: Trigger failed',
        name: packageName,
        error: e,
      );
    }
  }
}
