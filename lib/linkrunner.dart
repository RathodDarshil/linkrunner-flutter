import 'dart:convert';
import 'dart:developer' as developer;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models/api.dart';
import 'models/lr_user_data.dart';

class LinkRunner {
  static final LinkRunner _singleton = LinkRunner._internal();

  final String _baseUrl = 'https://api.linkrunner.io';
  final String encryptedStorageTokenKeyName = 'linkrunner-token';
  final String packageVersion = '0.5.2';

  static final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? token;

  LinkRunner._internal();

  factory LinkRunner() => _singleton;

  Future<Map<String, dynamic>> _getDeviceData() async {
    var deviceData = <String, dynamic>{};

    try {
      var deviceInfoData = await deviceInfo.deviceInfo;
      deviceData = deviceInfoData.data;
      // developer.log(deviceData.toString(), name: packageName);
      deviceData['package_version'] = packageVersion;
    } catch (e) {
      developer.log('Failed to get device info', error: e, name: packageName);
    }

    return deviceData;
  }

  Future<InitResponse?> init(String token) async {
    if (token.isEmpty) {
      developer.log(
        'Linkrunner needs your project token to initialize!',
        name: packageName,
      );
      return null;
    }

    this.token = token;

    try {
      Uri initURL = Uri.parse('$_baseUrl/api/client/init');

      dynamic body = {
        'token': token,
        'package_version': packageVersion,
        'app_version': (await _getDeviceData())['version'],
        'device_data': await _getDeviceData(),
        'platform': 'FLUTTER',
      };

      var response = await http.post(
        initURL,
        headers: jsonHeaders,
        body: jsonEncode(body),
      );

      var result = jsonDecode(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(result['msg']);
      }

      developer.log(
        'Linkrunner initialised successfully 🔥',
        name: packageName,
      );

      if (result?['data'] != null) {
        return InitResponse.fromJSON(result?['data']);
      }

      return null;
    } catch (e) {
      developer.log(
        'Error initializing Linkrunner',
        error: e,
        name: packageName,
      );

      return null;
    }
  }

  Future<Map<String, dynamic>?> trigger({
    required LRUserData userData,
    Map<String, dynamic>? data,
    TriggerConfig? config,
  }) async {
    if (token == null) {
      developer.log(
        'Trigger failed',
        name: packageName,
        error: Exception("linkrunner token not initialized"),
      );
      return null;
    }

    Uri triggerUrl = Uri.parse('$_baseUrl/api/client/trigger');

    final body = jsonEncode({
      'token': token,
      'user_data': userData.toJSON(),
      'platform': 'FLUTTER',
      'data': {
        ...?data,
        'device_data': await _getDeviceData(),
      },
    });

    try {
      var response = await http.post(
        triggerUrl,
        headers: jsonHeaders,
        body: body,
      );

      var result = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        developer.log(
          'Linkrunner: Trigger failed',
          name: packageName,
          error: jsonEncode(result['msg']),
        );

        throw Exception(result?.msg);
      }

      if (result['data'] != null) {
        final data = TriggerResponse.fromJSON(result?['data']);

        bool shouldTrigger = data.deeplink != null &&
            config?.triggerDeeplink != false &&
            data.trigger != null;

        if (shouldTrigger) {
          developer.log(
            'Linkrunner: Triggering deeplink > ${result?.data?.deeplink}',
            name: packageName,
          );

          Uri deeplinkUrl = Uri.parse(result?.data?.trigger ?? "");
          launchUrl(deeplinkUrl).then((launched) {
            if (launched) {
              Uri deeplinkTriggeredUri =
                  Uri.parse('$_baseUrl/api/client/deeplink-triggered');

              dynamic body = {
                'token': token,
              };

              http
                  .post(deeplinkTriggeredUri, headers: jsonHeaders, body: body)
                  .then(
                (res) {
                  developer.log(
                    'Linkrunner: Deeplink triggered successfully',
                    name: packageName,
                  );
                },
              ).catchError((error, stackTrace) {});
            }
          });
        }

        developer.log(
          'Linkrunner: Trigger called 🔥',
          name: packageName,
        );

        return result?['data'];
      }

      return null;
    } catch (e) {
      developer.log(
        'Linkrunner: Trigger failed',
        name: packageName,
        error: e,
      );

      return null;
    }
  }
}
