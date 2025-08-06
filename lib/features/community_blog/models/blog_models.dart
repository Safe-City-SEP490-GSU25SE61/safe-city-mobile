import 'package:safe_city_mobile/features/community_blog/models/province_with_commune_model.dart';
import 'commune_model.dart';

class BlogModel {
  final int id;
  final String title;
  final String content;
  final String type;
  final String authorName;
  final String avatarUrl;
  final DateTime createdAt;
  final bool pinned;
  final CommuneModel commune;
  final ProvinceWithCommunesModel province;
  final List<String> mediaUrls;
  final int totalLike;
  final int totalComment;
  final bool isLike;

  BlogModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.authorName,
    required this.avatarUrl,
    required this.createdAt,
    required this.pinned,
    required this.commune,
    required this.province,
    required this.mediaUrls,
    required this.totalLike,
    required this.totalComment,
    required this.isLike,
  });

  factory BlogModel.fromJson(
    Map<String, dynamic> json, {
    required ProvinceWithCommunesModel province,
    required CommuneModel commune,
  }) {
    return BlogModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      authorName: json['authorName'],
      avatarUrl: json['avaterUrl'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      pinned: json['pinned'],
      commune: commune,
      province: province,
      mediaUrls:
          (json['mediaUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
      totalLike: json['totalLike'],
      totalComment: json['totalComment'],
      isLike: json['isLike'],
    );
  }

  BlogModel copyWith({
    int? id,
    String? title,
    String? content,
    String? type,
    String? authorName,
    String? avatarUrl,
    DateTime? createdAt,
    bool? pinned,
    CommuneModel? commune,
    ProvinceWithCommunesModel? province,
    List<String>? mediaUrls,
    int? totalLike,
    int? totalComment,
    bool? isLike,
  }) {
    return BlogModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      authorName: authorName ?? this.authorName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      pinned: pinned ?? this.pinned,
      commune: commune ?? this.commune,
      province: province ?? this.province,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      totalLike: totalLike ?? this.totalLike,
      totalComment: totalComment ?? this.totalComment,
      isLike: isLike ?? this.isLike,
    );
  }

  String get typeInVietnamese {
    switch (type.toLowerCase()) {
      case 'tip':
        return 'Mẹo hay';
      case 'event':
        return 'Sự kiện';
      case 'news':
        return 'Tin tức';
      case 'alert':
        return 'Cảnh báo';
      default:
        return 'Khác';
    }
  }
}
