import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getLinkRunnerInstallInstanceId() async {
  const String key = 'linkrunner_install_instance_id';
  const int idLength = 20;

  final prefs = await SharedPreferences.getInstance();

  String? installInstanceId = prefs.getString(key);

  if (installInstanceId == null) {
    installInstanceId = _generateRandomString(idLength);
    await prefs.setString(key, installInstanceId);
  }

  return installInstanceId;
}

String _generateRandomString(int length) {
  const chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();

  return String.fromCharCodes(List.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
}
