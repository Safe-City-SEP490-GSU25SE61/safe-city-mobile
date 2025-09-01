import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/virtual_escort_group_controller.dart';

class VirtualEscortGroupPendingRequestScreen extends StatelessWidget {
  final int groupId;

  const VirtualEscortGroupPendingRequestScreen({
    super.key,
    required this.groupId,
  });


  Future<void> _handleRefresh(VirtualEscortGroupController controller) async {
    await controller.fetchGroupDetail(groupId);
    await controller.fetchPendingRequests(groupId);
  }

  @override
  Widget build(BuildContext context) {
    final controller = VirtualEscortGroupController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.lightGrey,
      appBar: const TAppBar(
        title: Text('Yêu cầu chờ duyệt'),
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _handleRefresh(controller),
        color: TColors.primary,
        child: Obx(() {
          if (controller.isLoadingGroupDetail.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final group = controller.groupDetail.value;
          if (group == null) {
            return const Center(child: Text("Không thể tải thông tin nhóm"));
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              /// Invite code card
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: Card(
                  color: TColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Mã mời thành viên",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Tooltip(
                              message: "Đây là mã mời thành viên vào nhóm của bạn",
                              child: Icon(
                                Icons.help_outline,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: TColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                group.groupCode,
                                style: TextStyle(
                                  color: TColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(Iconsax.copy, color: TColors.primary),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: group.groupCode),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Auto approve / receive request card
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  color: TColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Tự động phê duyệt\nTự động chấp nhận các yêu cầu tham gia nhóm",
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                            Obx(() => Switch(
                              value: controller.groupDetail.value?.autoApprove ?? false,
                              activeColor: TColors.primary,
                              onChanged: (val) {
                                final group = controller.groupDetail.value;
                                if (group == null) return;
                                controller.updateGroupSettings(
                                  groupCode: group.groupCode,
                                  autoApprove: val,
                                  receiveRequest: group.receiveRequest,
                                );
                              },
                            )),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Nhận yêu cầu tham gia\nCho phép thành viên gửi yêu cầu tham gia nhóm",
                                style: TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                            Obx(() => Switch(
                              value: controller.groupDetail.value?.receiveRequest ?? false,
                              activeColor: TColors.primary,
                              onChanged: (val) {
                                final group = controller.groupDetail.value;
                                if (group == null) return;
                                controller.updateGroupSettings(
                                  groupCode: group.groupCode,
                                  autoApprove: group.autoApprove,
                                  receiveRequest: val,
                                );
                              },
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// Pending requests
              Obx(() {
                if (controller.isLoadingPending.value) {
                  return SizedBox.shrink();
                }
                if (controller.pendingRequests.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("Không có yêu cầu chờ duyệt")),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
                  itemCount: controller.pendingRequests.length,
                  itemBuilder: (context, index) {
                    final req = controller.pendingRequests[index];
                    return Card(
                      color: TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          req.accountName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Yêu cầu lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(req.requestedAt)}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.verifyMemberRequest(
                                  groupId: groupId,
                                  requestId: req.id,
                                  approve: true,
                                );
                              },
                              icon: const Icon(Icons.check, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              onPressed: () {
                                controller.verifyMemberRequest(
                                  groupId: groupId,
                                  requestId: req.id,
                                  approve: false,
                                );
                              },
                              icon: const Icon(Icons.close, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          );
        }),
      ),
    );
  }
}
