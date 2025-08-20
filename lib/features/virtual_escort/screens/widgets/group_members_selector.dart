import 'package:flutter/material.dart';

import '../../models/virtual_escort_group_detail.dart';

class GroupMembersWidget extends StatefulWidget {
  final VirtualEscortGroupDetail? group;

  const GroupMembersWidget({super.key, this.group});

  @override
  State<GroupMembersWidget> createState() => _GroupMembersWidgetState();
}

class _GroupMembersWidgetState extends State<GroupMembersWidget> {
  final Set<int> _selectedMemberIds = {};

  @override
  Widget build(BuildContext context) {
    if (widget.group == null) {
      return const Center(child: Text("Không có dữ liệu nhóm"));
    }

    final members = widget.group!.members
        .where((m) => m.role != "Leader")
        .toList();

    if (members.isEmpty) {
      return const Center(child: Text("Không có thành viên nào"));
    }

    return SizedBox(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final isSelected = _selectedMemberIds.contains(member.id);

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedMemberIds.remove(member.id);
                } else {
                  _selectedMemberIds.add(member.id);
                }
              });
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.red : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: member.avatarUrl.isNotEmpty
                              ? NetworkImage(member.avatarUrl)
                              : null,
                          child: member.avatarUrl.isEmpty
                              ? Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


