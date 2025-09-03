class VirtualEscortPersonalHistory {
  final List<EscortGroup> escortGroups;
  final bool canReusePreviousEscortPaths;

  VirtualEscortPersonalHistory({
    required this.escortGroups,
    required this.canReusePreviousEscortPaths,
  });

  factory VirtualEscortPersonalHistory.fromJson(Map<String, dynamic> json) {
    return VirtualEscortPersonalHistory(
      escortGroups: (json['escortGroupDtos'] as List<dynamic>)
          .map((e) => EscortGroup.fromJson(e))
          .toList(),
      canReusePreviousEscortPaths: json['canReusePreviousEscortPaths'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "escortGroupDtos": escortGroups.map((e) => e.toJson()).toList(),
      "canReusePreviousEscortPaths": canReusePreviousEscortPaths,
    };
  }
}

class EscortGroup {
  final int id;
  final String startLocation;
  final String endLocation;
  final DateTime startTime;
  final DateTime endTime;
  final String vehicle;
  final String status;
  final List<Watcher> watchers;

  EscortGroup({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.startTime,
    required this.endTime,
    required this.vehicle,
    required this.status,
    required this.watchers,
  });

  factory EscortGroup.fromJson(Map<String, dynamic> json) {
    return EscortGroup(
      id: json['id'],
      startLocation: json['startLocation'] ?? '',
      endLocation: json['endLocation'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      vehicle: json['vehicle'] ?? '',
      status: json['status'] ?? '',
      watchers: (json['watchers'] as List<dynamic>)
          .map((e) => Watcher.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "startLocation": startLocation,
      "endLocation": endLocation,
      "startTime": startTime.toIso8601String(),
      "endTime": endTime.toIso8601String(),
      "vehicle": vehicle,
      "status": status,
      "watchers": watchers.map((e) => e.toJson()).toList(),
    };
  }
}

class Watcher {
  final int memberId;
  final String fullName;

  Watcher({required this.memberId, required this.fullName});

  factory Watcher.fromJson(Map<String, dynamic> json) {
    return Watcher(
      memberId: json['memberId'],
      fullName: json['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {"memberId": memberId, "fullName": fullName};
  }
}
