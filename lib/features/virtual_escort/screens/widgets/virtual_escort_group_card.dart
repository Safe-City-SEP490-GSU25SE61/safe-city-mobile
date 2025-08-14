import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/effects/shimmer_effect.dart';
import '../../../../utils/constants/colors.dart';
import '../../controllers/virtual_escort_group_controller.dart';
import '../../models/virtual_escort_group.dart';

class VirtualEscortGroupCard extends StatelessWidget {
  final EscortGroup group;
  final VoidCallback? onTap;

  const VirtualEscortGroupCard({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLeader = group.role.toLowerCase() == "leader";
    final controller = VirtualEscortGroupController.instance;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: TColors.purpleBlueGradient,
                ),
                child:Row(
                  children: [
                    if (isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.successContainer.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.star, color: TColors.success, size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Chủ sở hữu",
                              style: TextStyle(
                                color: TColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TColors.infoContainer.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Thành viên",
                          style: TextStyle(
                            color: TColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: TColors.purpleBlueGradient,
                ),
                child: Text(
                  group.name,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      if (controller.isLoadingGroup.value) {
                        return const TShimmerEffect(width: 10, height: 40);
                      }
                      return Text(
                        "${group.memberCount}/${group.maxMemberNumber} thành viên",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12
                        ),
                      );
                    }),
                    const Icon(Icons.chevron_right, size: 20,color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
