class BlogModel {
  final int id;
  final String title;
  final String content;
  final String type;
  final String authorName;
  final DateTime createdAt;
  final bool pinned;
  final String communeName;
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
    required this.createdAt,
    required this.pinned,
    required this.communeName,
    required this.mediaUrls,
    required this.totalLike,
    required this.totalComment,
    required this.isLike,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
      pinned: json['pinned'],
      communeName: json['communeName'],
      mediaUrls: List<String>.from(json['mediaUrls']),
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
    DateTime? createdAt,
    bool? pinned,
    String? communeName,
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
      createdAt: createdAt ?? this.createdAt,
      pinned: pinned ?? this.pinned,
      communeName: communeName ?? this.communeName,
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
      default:
        return 'Khác';
    }
  }
}
