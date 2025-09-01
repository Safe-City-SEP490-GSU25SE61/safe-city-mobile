class RouteStepModel {
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String instruction;
  double? speedLimit;

  RouteStepModel({
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.instruction,
    this.speedLimit,
  });

  factory RouteStepModel.fromJson(Map<String, dynamic> json) {
    return RouteStepModel(
      startLat: json['start_location']['lat'],
      startLng: json['start_location']['lng'],
      endLat: json['end_location']['lat'],
      endLng: json['end_location']['lng'],
      instruction: json['html_instructions'],
    );
  }
}
