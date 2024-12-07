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

class ClientCampaignData {
  final String id;
  final String name;
  final String type;
  final String? adNetwork;
  final String? groupName;
  final String? assetGroupName;
  final String? assetName;

  ClientCampaignData({
    required this.id,
    required this.name,
    required this.type,
    this.adNetwork,
    this.groupName,
    this.assetGroupName,
    this.assetName,
  });

  static ClientCampaignData? fromJSON(Map<String, dynamic>? json) {
    if (json == null) return null;
    return ClientCampaignData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      adNetwork: json['ad_network'],
      groupName: json['group_name'],
      assetGroupName: json['asset_group_name'],
      assetName: json['asset_name'],
    );
  }

  Map<String, dynamic> toJSON() => {
        'id': id,
        'name': name,
        'type': type,
        'ad_network': adNetwork,
        'group_name': groupName,
        'asset_group_name': assetGroupName,
        'asset_name': assetName,
      };
}

class InitResponse extends GeneralResponse {
  ClientCampaignData? campaignData;

  InitResponse();

  factory InitResponse.fromJSON(Map<String, dynamic>? json) => InitResponse()
    ..deeplink = json?['deeplink']
    ..rootDomain = json?['root_domain']
    ..ipLocationData = IPLocationData.fromJSON(json?['ip_location_data'])
    ..campaignData = ClientCampaignData.fromJSON(json?['campaign_data']);

  @override
  Map<String, dynamic> toJSON() {
    return {
      'deeplink': deeplink,
      'root_domain': rootDomain,
      'ip_location_data': ipLocationData?.toJSON(),
      'campaign_data': campaignData?.toJSON(),
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
