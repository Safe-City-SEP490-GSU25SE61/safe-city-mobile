class GoongPredictionModel {
  final String description;
  final String placeId;
  final String mainText;
  final String secondaryText;
  double? lat;
  double? lng;
  String? distanceText;
  String? updatedAddress;

  GoongPredictionModel({
    required this.description,
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.updatedAddress,
  });

  factory GoongPredictionModel.fromJson(Map<String, dynamic> json) {
    final formatting = json['structured_formatting'] ?? {};
    return GoongPredictionModel(
      description: json['description'],
      placeId: json['place_id'],
      mainText: formatting['main_text'] ?? '',
      secondaryText: formatting['secondary_text'] ?? '',
    );
  }

  String? get formattedDistance {
    if (distanceText == null) return null;

    final cleaned = distanceText!.replaceAll(" ", "");

    if (cleaned.endsWith("km")) {
      final kmValue = double.tryParse(cleaned.replaceAll("km", ""));
      if (kmValue != null) {
        return "${kmValue.ceil()}km";
      }
    } else if (cleaned.endsWith("m")) {
      final mValue = double.tryParse(cleaned.replaceAll("m", ""));
      if (mValue != null) {
        return "${mValue.toInt()}m";
      }
    }

    return cleaned;
  }
}
