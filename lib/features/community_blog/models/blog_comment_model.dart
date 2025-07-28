class CommentModel {
  final int id;
  final String content;
  final String authorName;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
