class BlogHistoryModel {
  final int id;
  final String title;
  final String content;
  final String type;
  final String authorName;
  final String avatarUrl;
  final DateTime createdAt;
  final bool pinned;
  final String communeName;
  final int totalLike;
  final int totalComment;
  final bool isLike;

  BlogHistoryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.authorName,
    required this.avatarUrl,
    required this.createdAt,
    required this.pinned,
    required this.communeName,
    required this.totalLike,
    required this.totalComment,
    required this.isLike,
  });

  factory BlogHistoryModel.fromJson(Map<String, dynamic> json) {
    return BlogHistoryModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      authorName: json['authorName'] as String,
      avatarUrl: json['avaterUrl'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      pinned: json['pinned'] as bool,
      communeName: json['communeName'] as String,
      totalLike: json['totalLike'] as int,
      totalComment: json['totalComment'] as int,
      isLike: json['isLike'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'authorName': authorName,
      'avaterUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'pinned': pinned,
      'communeName': communeName,
      'totalLike': totalLike,
      'totalComment': totalComment,
      'isLike': isLike,
    };
  }
}
