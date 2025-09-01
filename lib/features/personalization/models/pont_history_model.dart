import 'dart:convert';

class PointHistoryModel {
  final String userId;
  final int currentTotalPoint;
  final int currentReputationPoint;
  final List<PointHistoryItem> items;

  PointHistoryModel({
    required this.userId,
    required this.currentTotalPoint,
    required this.currentReputationPoint,
    required this.items,
  });

  factory PointHistoryModel.fromJson(Map<String, dynamic> json) {
    return PointHistoryModel(
      userId: json['userId'],
      currentTotalPoint: json['currentTotalPoint'],
      currentReputationPoint: json['currentReputationPoint'],
      items: (json['items'] as List)
          .map((e) => PointHistoryItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentTotalPoint': currentTotalPoint,
      'currentReputationPoint': currentReputationPoint,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  static PointHistoryModel fromRawJson(String str) =>
      PointHistoryModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class PointHistoryItem {
  final int id;
  final DateTime createdAt;
  final int pointsDelta;
  final int reputationDelta;
  final String sourceType;
  final String action;
  final String note;
  final String actorName;
  final Source source;

  PointHistoryItem({
    required this.id,
    required this.createdAt,
    required this.pointsDelta,
    required this.reputationDelta,
    required this.sourceType,
    required this.action,
    required this.note,
    required this.actorName,
    required this.source,
  });

  factory PointHistoryItem.fromJson(Map<String, dynamic> json) {
    return PointHistoryItem(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      pointsDelta: json['pointsDelta'],
      reputationDelta: json['reputationDelta'],
      sourceType: json['sourceType'],
      action: json['action'],
      note: json['note'],
      actorName: json['actorName'],
      source: Source.fromJson(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'pointsDelta': pointsDelta,
      'reputationDelta': reputationDelta,
      'sourceType': sourceType,
      'action': action,
      'note': note,
      'actorName': actorName,
      'source': source.toJson(),
    };
  }
}

class Source {
  final int id;
  final String? title;
  final String? status;
  final DateTime? occurredAt;
  final String? address;

  Source({
    required this.id,
    this.title,
    this.status,
    this.occurredAt,
    this.address,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      occurredAt: json['occurredAt'] != null
          ? DateTime.parse(json['occurredAt'])
          : null,
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'occurredAt': occurredAt?.toIso8601String(),
      'address': address,
    };
  }
}
