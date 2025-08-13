class ReportDetailModel {
  final String id;
  final int communeId;
  final String type;
  final String subCategory;
  final String address;
  final double lat;
  final double lng;
  final DateTime occurredAt;
  final String status;

  ReportDetailModel({
    required this.id,
    required this.communeId,
    required this.type,
    required this.subCategory,
    required this.address,
    required this.lat,
    required this.lng,
    required this.occurredAt,
    required this.status,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    return ReportDetailModel(
      id: json['id'],
      communeId: json['communeId'],
      type: json['type'],
      subCategory: json['subCategory'],
      address: json['address'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      occurredAt: DateTime.parse(json['occurredAt']),
      status: json['status'],
    );
  }
}
