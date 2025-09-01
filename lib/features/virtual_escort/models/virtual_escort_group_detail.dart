class VirtualEscortGroupDetail {
  final int id;
  final String name;
  final String groupCode;
  final int maxMemberNumber;
  final int currentMemberCount;
  final String leaderName;
  final DateTime createdAt;
  final List<VirtualEscortMember> members;
  final bool isLeader;
  final bool autoApprove;
  final bool receiveRequest;

  VirtualEscortGroupDetail({
    required this.id,
    required this.name,
    required this.groupCode,
    required this.maxMemberNumber,
    required this.currentMemberCount,
    required this.leaderName,
    required this.createdAt,
    required this.members,
    required this.isLeader,
    required this.autoApprove,
    required this.receiveRequest,
  });

  factory VirtualEscortGroupDetail.fromJson(Map<String, dynamic> json) {
    return VirtualEscortGroupDetail(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      groupCode: json["groupCode"] ?? "",
      maxMemberNumber: json["maxMemberNumber"] ?? 0,
      currentMemberCount: json["currentMemberCount"] ?? 0,
      leaderName: json["leaderName"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      members: (json["members"] as List<dynamic>? ?? [])
          .map((m) => VirtualEscortMember.fromJson(m as Map<String, dynamic>))
          .toList(),
      isLeader: json["isLeader"] ?? false,
      autoApprove: json["autoApprove"] ?? false,
      receiveRequest: json["receiveRequest"] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "groupCode": groupCode,
      "maxMemberNumber": maxMemberNumber,
      "currentMemberCount": currentMemberCount,
      "leaderName": leaderName,
      "createdAt": createdAt.toIso8601String(),
      "members": members.map((m) => m.toJson()).toList(),
      "isLeader": isLeader,
      "autoApprove": autoApprove,
      "receiveRequest": receiveRequest,
    };
  }
}

class VirtualEscortMember {
  final int id;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String role;
  final String escortStatus;

  VirtualEscortMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.role,
    required this.escortStatus,
  });

  factory VirtualEscortMember.fromJson(Map<String, dynamic> json) {
    return VirtualEscortMember(
      id: json["id"] ?? 0,
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      avatarUrl: json["avatarUrl"] ?? "",
      role: json["role"] ?? "",
      escortStatus: json["escortStatus"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "avatarUrl": avatarUrl,
      "role": role,
      "escortStatus": escortStatus,
    };
  }
}