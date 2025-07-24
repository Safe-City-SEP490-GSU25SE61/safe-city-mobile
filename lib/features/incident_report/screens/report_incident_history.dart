import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:safe_city_mobile/features/incident_report/screens/report_detail_screen.dart';

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
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown<ReportRange>(
                    label: 'Khoảng thời gian',
                    value: historyController.selectedRange.value,
                    items: historyController.rangeOptions,
                    getLabel: (e) => e.label,
                    onChanged: (val) =>
                        historyController.updateFilters(range: val),
                  ),
                ),
                const SizedBox(width: TSizes.smallSpace),
                Expanded(
                  child: _buildDropdown<ReportStatus>(
                    label: 'Trạng thái',
                    value: historyController.selectedStatus.value,
                    items: historyController.statusOptions,
                    getLabel: (e) => e.label,
                    onChanged: (val) =>
                        historyController.updateFilters(status: val),
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
                          width: 250,
                          height: 250,
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
                    return Card(
                      color: dark ? TColors.white : TColors.lightGrey,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () =>
                            Get.to(() => ReportDetailScreen(report: item)),
                        title: Text(
                          item.type,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
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

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: [
        DropdownMenuItem<T>(value: null, child: Text("Tất cả")),
        ...items.map(
          (e) => DropdownMenuItem<T>(value: e, child: Text(getLabel(e))),
        ),
      ],
      onChanged: onChanged,
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
