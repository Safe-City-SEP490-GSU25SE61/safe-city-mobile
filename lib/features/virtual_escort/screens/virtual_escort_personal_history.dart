import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/virtual_escort_group_controller.dart';

class VirtualEscortPersonalHistoryScreen extends StatelessWidget {
  VirtualEscortPersonalHistoryScreen({super.key});

  final controller = Get.put(VirtualEscortGroupController());

  Future<void> _handleRefresh() async {
    await controller.fetchPersonalHistory();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPersonalHistory();
    });
    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.lightGrey,
      appBar: TAppBar(
        title: const Text('Lịch sử hành trình của bạn'),
        showBackArrow: true,
      ),
      body: Obx(() {
        if (controller.isLoadingHistory.value) {
          return const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          );
        }

        final history = controller.historyPersonal.value;
        if (history == null || history.escortGroups.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(TImages.emptyBoxImage, width: 200, height: 200),
                const SizedBox(height: 10),
                const Text("Không có lịch sử hành trình"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: TColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: history.escortGroups.length,
            itemBuilder: (context, index) {
              final item = history.escortGroups[index];

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Left timeline (pickup → destination)
                      Column(
                        children: [
                          Icon(Icons.location_on, color: TColors.primary, size: 20),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey.shade300,
                          ),
                          Icon(Icons.flag, color: Colors.redAccent, size: 20),

                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          if (item.watchers.isNotEmpty)
                            Icon(Iconsax.timer_1, color: TColors.accent, size: 20),

                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          if (item.watchers.isNotEmpty)
                            Icon(Iconsax.eye4, color: TColors.accent, size: 20),
                        ],
                      ),
                      const SizedBox(width: 10),

                      /// Middle content (addresses + observers)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Start Location
                            Text(
                              item.startLocation,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text("Điểm bắt đầu",
                                style: TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 12),

                            /// End Location
                            Text(
                              item.endLocation,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.black),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text("Đích đến",
                                style: TextStyle(color: Colors.black54, fontSize: 12)),

                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  "${DateFormat("dd/MM/yy HH:mm").format(item.startTime)} → "
                                      "${DateFormat("dd/MM/yy HH:mm").format(item.endTime)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),

                            // timer here seperate
                            /// Observers (horizontal scroll chips)
                            const SizedBox(height: 16),
                            if (item.watchers.isNotEmpty) ...[
                              const SizedBox(height: 15),
                              const Text(
                                "Giám sát bởi:",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 30,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: item.watchers.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                                  itemBuilder: (context, i) {
                                    final watcher = item.watchers[i];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: TColors.infoContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        watcher.fullName,
                                        style: const TextStyle(
                                          color: TColors.info,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      /// Right side info (status & duration)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: TColors.successContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.status == "Completed" ? "Hoàn thành" : item.status,
                              style: TextStyle(
                                color: TColors.success,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "${item.endTime.difference(item.startTime).inMinutes} phút",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
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
    );
  }
}
