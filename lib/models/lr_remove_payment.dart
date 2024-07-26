class LRRemovePayment {
  final String? paymentId;
  final String? userId;

  LRRemovePayment._({this.paymentId, this.userId});

  factory LRRemovePayment({String? paymentId, String? userId}) {
    if (paymentId == null && userId == null) {
      throw ArgumentError('Either paymentId or userId must be provided');
    }
    return LRRemovePayment._(paymentId: paymentId, userId: userId);
  }

  Map<String, String> toJSON() {
    final map = <String, String>{};
    if (paymentId != null) map['payment_id'] = paymentId!;
    if (userId != null) map['user_id'] = userId!;
    return map;
  }
}
