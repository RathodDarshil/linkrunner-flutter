class IPLocationData {
  String? ip;
  String? city;
  String? countryLong;
  String? countryShort;
  num? latitude;
  num? longitude;
  String? region;
  String? timeZone;
  String? zipCode;

  IPLocationData();

  factory IPLocationData.fromJSON(Map<String, dynamic> json) {
    return IPLocationData()
      ..ip = json['ip'] ?? ""
      ..city = json['city'] ?? ""
      ..countryLong = json['countryLong'] ?? ""
      ..countryShort = json['countryShort'] ?? ""
      ..latitude = json['latitude'] ?? 0.0
      ..longitude = json['longitude'] ?? 0.0
      ..region = json['region'] ?? ""
      ..timeZone = json['timeZone'] ?? ""
      ..zipCode = json['zipCode'] ?? "";
  }

  Map<String, dynamic> toJSON() {
    return {
      'ip': ip,
      'city': city,
      'countryLong': countryLong,
      'countryShort': countryShort,
      'latitude': latitude,
      'longitude': longitude,
      'region': region,
      'timeZone': timeZone,
      'zipCode': zipCode,
    };
  }
}
