class SubscriptionPackageModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final int durationDays;
  final String color;
  final DateTime createAt;
  final DateTime lastUpdated;
  final bool isActive;

  SubscriptionPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.color,
    required this.createAt,
    required this.lastUpdated,
    required this.isActive,
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackageModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      durationDays: json['durationDays'],
      color: json['color'],
      createAt: DateTime.parse(json['createAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isActive: json['isActive'],
    );
  }
}
