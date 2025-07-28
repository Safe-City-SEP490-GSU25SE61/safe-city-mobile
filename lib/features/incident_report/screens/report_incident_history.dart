import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:safe_city_mobile/features/incident_report/screens/report_detail_screen.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/filter_history_modal.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/incident_report_controller.dart';

class ReportHistoryScreen extends StatelessWidget {
  ReportHistoryScreen({super.key});

  final historyController = Get.put(IncidentReportController());

  Future<void> _handleRefresh() async {
    await historyController.fetchReportHistory();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Lịch sử báo cáo'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  controller: historyController.searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm báo cáo...',
                    hintStyle: const TextStyle(color: Colors.black),
                    prefixIcon: const Icon(Iconsax.search_normal),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    historyController.updateFilters(communeName: value);
                    historyController.fetchReportHistory();
                  },
                ),

                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => FilterHistoryModal(
                        onApply: () => historyController.fetchReportHistory(),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Lọc báo cáo",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Icon(Icons.filter_list),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: TColors.primary,
              child: Obx(() {
                if (historyController.isLoadingReportHistory.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: TColors.primary),
                  );
                }

                if (historyController.reportHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image.asset(
                          TImages.emptyBoxImage,
                          width: 240,
                          height: 240,
                        ),
                        const Text(
                          "Không có lịch sử đăng ký",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(TSizes.md),
                  itemCount: historyController.reportHistory.length,
                  itemBuilder: (context, index) {
                    final item = historyController.reportHistory[index];
                    final statusEnum = ReportStatus.values.firstWhere(
                      (e) => e.value == item.status,
                      orElse: () => ReportStatus.pending,
                    );
                    final normalizedPriority = item.priorityLevel
                        .trim()
                        .toLowerCase();

                    final priorityEnum = ReportPriority.values.firstWhere(
                      (e) => e.value == normalizedPriority,
                      orElse: () => ReportPriority.low,
                    );

                    return Card(
                      color: dark ? TColors.white : TColors.lightGrey,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () =>
                            Get.to(() => ReportDetailScreen(report: item)),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.type,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                            Text(
                              item.subCategory!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TColors.primary,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _subtitleRow("Địa điểm", item.address),
                            _subtitleRow(
                              "Thời gian xảy ra",
                              DateFormat('yyyy-MM-dd').format(item.occurredAt),
                            ),
                            _subtitleRow(
                              "Trạng thái",
                              statusEnum.label,
                              valueColor: statusEnum.color,
                            ),
                            _subtitleRow(
                              "Mức độ nghiêm trọng",
                              priorityEnum.label,
                              valueColor: priorityEnum.color,
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Iconsax.arrow_right,
                          color: TColors.primary,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitleRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
