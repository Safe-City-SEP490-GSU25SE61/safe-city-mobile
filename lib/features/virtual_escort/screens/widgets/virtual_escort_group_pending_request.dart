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

  @override
  Widget build(BuildContext context) {
    final controller = VirtualEscortGroupController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGroupDetail(groupId);
      controller.fetchPendingRequests(groupId);
    });

    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.lightGrey,
      appBar: const TAppBar(
        title: Text('Yêu cầu chờ duyệt'),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoadingGroupDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final group = controller.groupDetail.value;
        if (group == null) {
          return const Center(child: Text("Không thể tải thông tin nhóm"));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                color: dark ? TColors.white : TColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold,),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Mã nhóm:",
                                style: TextStyle(color: Colors.black,fontSize: 14),
                              ),
                              const SizedBox(width: 32),
                              Text(
                                group.groupCode,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      color: TColors.accent,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Iconsax.copy, color: TColors.darkerGrey),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: group.groupCode),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoadingPending.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.pendingRequests.isEmpty) {
                  return const Center(
                    child: Text("Không có yêu cầu chờ duyệt"),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.pendingRequests.length,
                  itemBuilder: (context, index) {
                    final req = controller.pendingRequests[index];
                    return Card(
                      color: dark ? TColors.white : TColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          req.accountName,
                          style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Ngày yêu cầu: ${DateFormat('dd/MM/yyyy HH:mm').format(req.requestedAt)}",
                          style: TextStyle(color: Colors.black),
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
            ),
          ],
        );
      }),
    );
  }
}
