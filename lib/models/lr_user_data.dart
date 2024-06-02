class LRUserData {
  final String id;
  final String? name;
  final String? phone;
  final String? email;

  LRUserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  Map<String, String?> toJSON() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
    };
  }
}
