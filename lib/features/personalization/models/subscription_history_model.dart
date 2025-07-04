class SubscriptionHistoryModel {
  final String orderCode;
  final int amount;
  final int quantity;
  final String paymentMethod;
  final String status;
  final String paidAt;
  final String packageName;

  SubscriptionHistoryModel({
    required this.orderCode,
    required this.amount,
    required this.quantity,
    required this.paymentMethod,
    required this.status,
    required this.paidAt,
    required this.packageName,
  });

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryModel(
      orderCode: json['orderCode'],
      amount: json['amount'],
      quantity: json['quantity'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      paidAt: json['paidAt'],
      packageName: json['packageName'],
    );
  }
}
