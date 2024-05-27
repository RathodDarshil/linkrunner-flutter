import 'dart:convert';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

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
  static final LinkRunner _singleton = LinkRunner._internal();

  final String _baseUrl = 'https://api.linkrunner.io';
  final String encryptedStorageTokenKeyName = 'linkrunner-token';
  final String packageVersion = '0.5.2';

  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? token;

  factory LinkRunner.getInstance() {
    return _singleton;
  }

  LinkRunner._internal();

  Future<Map<String, dynamic>> _getDeviceData() async {
    var deviceData = <String, dynamic>{};

    try {
      var deviceInfoData = await deviceInfo.deviceInfo;
      deviceData = deviceInfoData.data;
      developer.log(deviceData.toString(), name: packageName);
      deviceData['package_version'] = packageVersion;
    } catch (e) {
      developer.log('Failed to get device info', error: e, name: packageName);
    }

    return deviceData;
  }

  Future<void> init(String token) async {
    if (token.isEmpty) {
      developer.log(
        'Linkrunner needs your project token to initialize!',
        name: packageName,
      );
      return;
    }

    this.token = token;

    try {
      var response = await http.post(
        Uri.parse('$_baseUrl/api/client/init'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'package_version': packageVersion,
          'app_version': (await _getDeviceData())['version'],
          'device_data': await _getDeviceData(),
          'platform': 'FLUTTER',
        }),
      );

      var result = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // await secureStorage.write(
        //     key: encryptedStorageTokenKeyName, value: token);
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

  Future<void> trigger({
    required LRUserData userData,
    Map<String, dynamic>? data,
  }) async {
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
        'device_data': await _getDeviceData(),
      },
    });

    try {
      var response = await http.post(
        Uri.parse('$_baseUrl/api/client/trigger'),
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
