import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/incident_report/screens/report_incident_history.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/date_time_picker.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/live_map.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/popup_modal.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/incident_report_controller.dart';

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // 🔥 TODO: Add your API call here to refresh membership data
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final reportController = Get.put(IncidentReportController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Báo cáo sự cố',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          InkWell(
            onTap: () => Get.to(() => ReportHistoryScreen()),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: const [
                  Icon(Iconsax.refresh, color: Colors.black, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Lịch sử',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: TSizes.mediumSpace),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(TSizes.mediumSpace),
          children: [
            Form(
              key: reportController.incidentReportFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Thông tin người báo cáo",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: reportController.isAnonymous.value,
                              onChanged: (value) {
                                reportController.isAnonymous.value =
                                    !reportController.isAnonymous.value;
                                PopUpModal().showOkOnlyDialog(
                                  title: 'Chế độ ẩn danh',
                                  message: reportController.isAnonymous.value
                                      ? TTexts.anonymousReportOnNotice
                                      : TTexts.anonymousReportOffNotice,
                                );
                              },
                            ),
                          ),
                          const Text(
                            'Ẩn danh',
                            style: TextStyle(
                              fontSize: 16,
                              color: TColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: TSizes.spaceBtwItems),
                  const Text(
                    "Thông tin vụ việc",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Loại báo cáo
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Loại báo cáo ',
                          style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      prefixIcon: Icon(Iconsax.activity),
                    ),
                    value: reportController.type.value,
                    items: const [
                      DropdownMenuItem(
                        value: 'Littering',
                        child: Text("Xả rác"),
                      ),
                      DropdownMenuItem(
                        value: 'TrafficJam',
                        child: Text("Kẹt xe"),
                      ),
                      DropdownMenuItem(
                        value: 'Accident',
                        child: Text("Tai nạn"),
                      ),
                      DropdownMenuItem(value: 'Fighting', child: Text("Ẩu đả")),
                      DropdownMenuItem(value: 'Theft', child: Text("Trộm cắp")),
                      DropdownMenuItem(
                        value: 'PublicDisorder',
                        child: Text("Gây rối trật tự công cộng"),
                      ),
                      DropdownMenuItem(
                        value: 'Vandalism',
                        child: Text("Phá hoại tài sản"),
                      ),
                      DropdownMenuItem(value: 'Other', child: Text("Khác")),
                    ],
                    onChanged: (value) => reportController.type.value = value,
                    validator: (value) =>
                        TValidator.validateDropdown("loại báo cáo", value),
                  ),

                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Địa điểm xảy ra
                  TextFormField(
                    readOnly: true,
                    controller: reportController.address,
                    validator: (value) =>
                        TValidator.validateEmptyText("Địa điểm xảy ra", value),
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Địa điểm xảy ra ',
                          style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      prefixIcon: const Icon(Iconsax.location),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await Get.to(() => const LiveMapScreen());
                        },
                        icon: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark
                                ? TColors.white.withValues(alpha: 0.9)
                                : TColors.softGrey.withValues(alpha: 0.9),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Iconsax.gps,
                            color: TColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  DateTimePickerField(
                    onChanged: (selectedDateTime) {
                      if (selectedDateTime != null) {
                        reportController.occurredAt.value = selectedDateTime
                            .toUtc()
                            .toIso8601String();
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Mô tả chi tiết
                  TextFormField(
                    controller: reportController.description,
                    maxLines: 5,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Mô tả chi tiết ',
                          style: TextStyle(
                            color: dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      prefixIcon: const Icon(Iconsax.edit),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        TValidator.validateEmptyText("Mô tả", value),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Bằng chứng
                  RichText(
                    text: TextSpan(
                      text: 'Bằng chứng ',
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  GestureDetector(
                    onTap: reportController.pickMedia,
                    child: Obx(() {
                      final hasMedia =
                          reportController.images.isNotEmpty ||
                          reportController.video.value != null;

                      return Container(
                        width: double.infinity,
                        height: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: hasMedia
                            ? ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  ...reportController.images
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final index = entry.key;
                                        final file = entry.value;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(file.path!),
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () => reportController
                                                      .images
                                                      .removeAt(index),
                                                  child: const Icon(
                                                    Iconsax.close_circle,
                                                    color: Colors.redAccent,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                  if (reportController.video.value != null)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Iconsax.video,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  reportController.video.value =
                                                      null,
                                              child: const Icon(
                                                Iconsax.close_circle,
                                                color: Colors.redAccent,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.document_upload,
                                    size: 36,
                                    color: dark
                                        ? TColors.lightDarkGrey
                                        : TColors.darkerGrey,
                                  ),
                                  const SizedBox(height: 12),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              "Nhấn để tải lên hình ảnh hoặc video liên quan đến vụ việc.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: dark
                                                ? TColors.lightDarkGrey
                                                : TColors.darkerGrey,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Tối đa ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: dark
                                                ? TColors.white
                                                : TColors.darkGrey,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "3 bức ảnh",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: dark
                                                ? TColors.lightDarkGrey
                                                : TColors.darkerGrey,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " hoặc ",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: dark
                                                ? TColors.white
                                                : TColors.darkGrey,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "1 video không quá 200MB",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: dark
                                                ? TColors.lightDarkGrey
                                                : TColors.darkerGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                      );
                    }),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),

                  /// Lưu ý
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: TColors.warningContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Iconsax.lamp_on, color: TColors.warning),
                        const SizedBox(width: TSizes.xs),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: TColors.warning,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(
                                  text: '${TTexts.emergencyHelpNoticeTitle}\n',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                TextSpan(text: TTexts.emergencyHelpNotice),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Gửi báo cáo
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                      ),
                      onPressed: () {
                        PopUpModal().showConfirmCancelDialog(
                          title: 'Lưu ý khi gửi báo cáo',
                          message: TTexts.incidentReportNotice,
                          onConfirm: () {
                            reportController.submitReport();
                          },
                          storageKey: 'hide_incident_report_notice',
                        );
                      },
                      child: const Text("Gửi báo cáo"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
