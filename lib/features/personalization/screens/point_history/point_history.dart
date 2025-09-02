import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:safe_city_mobile/features/personalization/screens/point_history/widgets/point_history_modal.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/profile/user_profile_controller.dart';

class PointHistoryScreen extends StatelessWidget {
  PointHistoryScreen({super.key});

  final controller = Get.put(UserProfileController());

  Future<void> _handleRefresh() async {
    await controller.fetchPointHistory();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: dark ? TColors.black : TColors.lightGrey,
      appBar: TAppBar(
        title: const Text('Lịch sử điểm'),
        showBackArrow: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: dark ? TColors.white : TColors.black,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    PointHistoryFilterModal(onApply: _handleRefresh),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingPointHistory.value) {
          return const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          );
        }

        final history = controller.pointHistory.value;
        if (history == null || history.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(TImages.emptyBoxImage, width: 200, height: 200),
                const SizedBox(height: 10),
                const Text("Không có lịch sử điểm"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: TColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: history.items.length,
            itemBuilder: (context, index) {
              final item = history.items[index];

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: item.pointsDelta >= 0
                        ? TColors.success
                        : Colors.red,
                    child: Text(
                      "${item.pointsDelta >= 0 ? "+" : ""}${item.pointsDelta}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    THelperFunctions.mapSourceTypeToVietnamese(item.sourceType),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subtitleRow("Người thực hiện", item.actorName),
                      if (item.note.isNotEmpty)
                        _subtitleRow("Ghi chú", item.note),
                      _subtitleRow(
                        "Ngày",
                        DateFormat('yyyy-MM-dd HH:mm').format(item.createdAt),
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _subtitleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(color: Colors.black54),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
