class AchievementModel {
  final int id;
  final String name;
  final String description;
  final int minPoint;
  final String benefit;
  final DateTime createAt;
  final DateTime lastUpdated;
  final String imageUrl;

  AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.minPoint,
    required this.benefit,
    required this.createAt,
    required this.lastUpdated,
    required this.imageUrl,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      minPoint: json['minPoint'],
      benefit: json['benefit'],
      createAt: DateTime.parse(json['createAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      imageUrl: json['imageUrl'],
    );
  }
}
