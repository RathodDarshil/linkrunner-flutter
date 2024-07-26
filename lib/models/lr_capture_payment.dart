class LRCapturePayment {
  final String? paymentId;
  final String userId;
  final double amount;

  LRCapturePayment({
    this.paymentId,
    required this.userId,
    required this.amount,
  });

  Map<String, dynamic> toJSON() {
    Map<String, dynamic> json = {
      'user_id': userId,
      'amount': amount,
    };

    if (paymentId != null) {
      json['payment_id'] = paymentId;
    }

    return json;
  }
}
