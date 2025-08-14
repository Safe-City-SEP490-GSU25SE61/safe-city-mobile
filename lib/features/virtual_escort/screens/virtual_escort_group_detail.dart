import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/common/widgets/effects/shimmer_effect.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_journey_create.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/virtual_escort_group_pending_request.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../controllers/virtual_escort_group_controller.dart';

class VirtualEscortGroupDetailPage extends StatelessWidget {
  final int groupId;

  const VirtualEscortGroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final controller = VirtualEscortGroupController.instance;

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.fetchGroupDetail(groupId);
    // });

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Giám sát an toàn'),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoadingGroupDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final detail = controller.groupDetail.value;
        if (detail == null) {
          return const Center(child: Text("Không có dữ liệu nhóm"));
        }

        return SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 160,
                decoration: const BoxDecoration(
                  gradient: TColors.purpleBlueGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 10,
                      top: 4,
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 22,
                          color: Colors.white,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') {
                            showDeleteGroupDialog(context, detail.groupCode);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'delete',
                                height: 30,
                                child: Text('Xóa nhóm'),
                              ),
                            ],
                      ),
                    ),

                    Positioned(
                      left: 16,
                      top: 16,
                      child: SizedBox(
                        width: 280,
                        child: Text(
                          "Nhóm ${detail.name}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: InkWell(
                        onTap: () {
                          // TODO: Add your "Change Image" logic here
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Iconsax.camera,
                                color: Colors.black,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Đổi ảnh",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Get.to(() => VirtualEscortJourneyCreate()),
                        icon: const Icon(Iconsax.add, size: 24),
                        label: const Text(
                          "Tạo giám sát",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(
                          () => VirtualEscortGroupPendingRequestScreen(
                            groupId: groupId,
                          ),
                        ),
                        icon: const Icon(Iconsax.scan, size: 20),
                        label: const Text(
                          "Duyệt thành viên",
                          style: TextStyle(fontSize: 14),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: TSizes.spaceBtwItems),

              Expanded(
                child: Obx(() {
                  if (controller.isLoadingGroupDetail.value) {
                    return const TShimmerEffect(width: 60, height: 300);
                  }

                  final detail = controller.groupDetail.value;
                  if (detail == null || detail.members.isEmpty) {
                    return const Center(child: Text("Không có thành viên"));
                  }
                  return Container(
                    color: TColors.lightGrey,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: detail.members.length,
                      itemBuilder: (context, index) {
                        final member = detail.members[index];
                        return Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          (member.avatarUrl.isNotEmpty)
                                          ? NetworkImage(member.avatarUrl)
                                          : const AssetImage(
                                                  TImages.userImageMale,
                                                )
                                                as ImageProvider,
                                      backgroundColor: Colors.grey,
                                      radius: 30,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          truncateWithEllipsis(
                                            14,
                                            member.fullName,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          "abc@gmail.com",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (member.role.toLowerCase() ==
                                                'leader')
                                            ? TColors.successContainer
                                                  .withValues(alpha: 0.9)
                                            : TColors.infoContainer.withValues(
                                                alpha: 0.9,
                                              ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (member.role.toLowerCase() ==
                                              'leader') ...[
                                            const Icon(
                                              Icons.star,
                                              color: Colors.green,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              "Chủ sở hữu",
                                              style: TextStyle(
                                                color: TColors.success,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ] else ...[
                                            const Text(
                                              "Thành viên",
                                              style: TextStyle(
                                                color: TColors.info,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // TODO: Add your "more options" logic here
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  void showDeleteGroupDialog(BuildContext context, String groupCode) {
    final controller = VirtualEscortGroupController.instance;

    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Xóa nhóm',
      middleText: 'Bạn có chắc muốn xóa nhóm này không?',
      confirm: ElevatedButton(
        onPressed: () async {
          Navigator.of(Get.overlayContext!).pop();
          await controller.deleteGroup(groupCode);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: TSizes.lg),
          child: Text('Đồng ý'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Hủy bỏ'),
      ),
    );
  }

  String truncateWithEllipsis(int cutoff, String text) {
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }
}
