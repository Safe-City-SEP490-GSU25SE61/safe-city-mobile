class VirtualEscortPendingRequest {
  final int id;
  final String accountId;
  final String accountName;
  final DateTime requestedAt;

  VirtualEscortPendingRequest({
    required this.id,
    required this.accountId,
    required this.accountName,
    required this.requestedAt,
  });

  factory VirtualEscortPendingRequest.fromJson(Map<String, dynamic> json) {
    return VirtualEscortPendingRequest(
      id: json["id"],
      accountId: json["accountId"],
      accountName: json["accountName"],
      requestedAt: DateTime.parse(json["requestedAt"]),
    );
  }
}
