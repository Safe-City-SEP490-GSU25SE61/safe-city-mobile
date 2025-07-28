class IncidentReportModel {
  final bool isAnonymous;
  final double lat;
  final double lng;
  final String address;
  final String occurredAt;
  final String type;
  final String subCategory;
  final String description;
  final String priorityLevel;

  IncidentReportModel({
    required this.isAnonymous,
    required this.lat,
    required this.lng,
    required this.address,
    required this.occurredAt,
    required this.type,
    required this.subCategory,
    required this.description,
    required this.priorityLevel,
  });

  Map<String, String> toFormFields() {
    return {
      'IsAnonymous': isAnonymous.toString(),
      'Lat': lat.toString(),
      'Lng': lng.toString(),
      'Address': address,
      'OccurredAt': occurredAt,
      'Type': type,
      'SubCategory': subCategory,
      'Description': description,
      'PriorityLevel': priorityLevel,
    };
  }
}
