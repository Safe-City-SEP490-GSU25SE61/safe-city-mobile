class EscortGroup {
  final int id;
  final String name;
  final String role;
  final int memberCount;
  final int maxMemberNumber;

  EscortGroup({
    required this.id,
    required this.name,
    required this.role,
    required this.memberCount,
    required this.maxMemberNumber,
  });

  factory EscortGroup.fromJson(Map<String, dynamic> json) {
    return EscortGroup(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      role: json["role"] ?? "",
      memberCount: json["memberCount"] ?? 0,
      maxMemberNumber: json["maxMemberNumber"] ?? 0,
    );
  }
}
