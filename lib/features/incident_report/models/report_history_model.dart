class ReportHistoryModel {
  final String id;
  final String type;
  final String description;
  final String address;
  final DateTime occurredAt;
  final String status;
  final bool isAnonymous;
  final DateTime createdAt;
  final List<String> imageUrls;
  final String? videoUrl;

  ReportHistoryModel({
    required this.id,
    required this.type,
    required this.description,
    required this.address,
    required this.occurredAt,
    required this.status,
    required this.isAnonymous,
    required this.createdAt,
    required this.imageUrls,
    this.videoUrl,
  });

  factory ReportHistoryModel.fromJson(Map<String, dynamic> json) {
    return ReportHistoryModel(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      address: json['address'],
      occurredAt: DateTime.parse(json['occurredAt']),
      status: json['status'],
      isAnonymous: json['isAnonymous'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrl: json['videoUrl'],
    );
  }
}
