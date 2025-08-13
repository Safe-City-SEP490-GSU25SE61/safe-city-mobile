import 'commune_model.dart';

class ProvinceWithCommunesModel {
  final int id;
  final String name;
  final List<CommuneModel> communes;

  ProvinceWithCommunesModel({
    required this.id,
    required this.name,
    required this.communes,
  });

  factory ProvinceWithCommunesModel.fromJson(Map<String, dynamic> json) {
    return ProvinceWithCommunesModel(
      id: json['id'],
      name: json['name'],
      communes: (json['communes'] as List<dynamic>)
          .map((c) => CommuneModel.fromJson(c))
          .toList(),
    );
  }
}
