import 'ip_location_data.dart';

class TriggerConfig {
  final bool triggerDeeplink;

  TriggerConfig({
    required this.triggerDeeplink,
  });
}

abstract class GeneralResponse {
  IPLocationData? ipLocationData;
  String? deeplink;
  bool? rootDomain;

  GeneralResponse();

  GeneralResponse.fromJSON(Map<String, dynamic>? json);

  Map<String, dynamic> toJSON();
}

class InitResponse extends GeneralResponse {
  InitResponse();

  factory InitResponse.fromJSON(Map<String, dynamic>? json) => InitResponse()
    ..deeplink = json?['deeplink']
    ..rootDomain = json?['root_domain']
    ..ipLocationData = IPLocationData.fromJSON(json?['ip_location_data']);

  @override
  Map<String, dynamic> toJSON() {
    return {
      'deeplink': deeplink,
      'root_domain': rootDomain,
      'ip_location_data': ipLocationData?.toJSON(),
    };
  }
}

class TriggerResponse extends GeneralResponse {
  bool? trigger;

  TriggerResponse();

  factory TriggerResponse.fromJSON(Map<String, dynamic>? json) =>
      TriggerResponse()
        ..deeplink = json?['deeplink']
        ..rootDomain = json?['root_domain']
        ..ipLocationData = IPLocationData.fromJSON(json?['ip_location_data'])
        ..trigger = json?['trigger'];

  @override
  Map<String, dynamic> toJSON() {
    return {
      'deeplink': deeplink,
      'root_domain': rootDomain,
      'ip_location_data': ipLocationData?.toJSON(),
      'trigger': trigger,
    };
  }
}
