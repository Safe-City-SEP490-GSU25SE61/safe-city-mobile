class GoongPredictionModel {
  final String description;
  final String placeId;

  GoongPredictionModel({required this.description, required this.placeId});

  factory GoongPredictionModel.fromJson(Map<String, dynamic> json) {
    return GoongPredictionModel(
      description: json['description'],
      placeId: json['place_id'],
    );
  }
}
