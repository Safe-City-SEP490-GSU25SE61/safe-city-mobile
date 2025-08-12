class VirtualEscortGroupDetail {
  final int id;
  final String name;
  final String groupCode;
  final int maxMemberNumber;
  final int currentMemberCount;
  final String leaderName;
  final DateTime createdAt;
  final List<VirtualEscortMember> members;

  VirtualEscortGroupDetail({
    required this.id,
    required this.name,
    required this.groupCode,
    required this.maxMemberNumber,
    required this.currentMemberCount,
    required this.leaderName,
    required this.createdAt,
    required this.members,
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
          .map((m) => VirtualEscortMember.fromJson(m))
          .toList(),
    );
  }
}

class VirtualEscortMember {
  final int id;
  final String fullName;
  final String avatarUrl;
  final String role;

  VirtualEscortMember({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
  });

  factory VirtualEscortMember.fromJson(Map<String, dynamic> json) {
    return VirtualEscortMember(
      id: json["id"] ?? 0,
      fullName: json["fullName"] ?? "",
      avatarUrl: json["avatarUrl"] ?? "",
      role: json["role"] ?? "",
    );
  }
}
