import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/features/incident_report/screens/report_incident_history.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/date_time_picker.dart';
import 'package:safe_city_mobile/features/incident_report/screens/widgets/live_map.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../common/widgets/popup/popup_modal.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/incident_report_controller.dart';

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    final reportController = Get.put(IncidentReportController());
    reportController.clearReportForm();
  }

  @override
  Widget build(BuildContext context) {
    final popUpModal = PopUpModal.instance;
    final dark = THelperFunctions.isDarkMode(context);
    final reportController = Get.put(IncidentReportController());
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Báo cáo sự cố',
          style: TextStyle(fontSize: 20),
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
          padding: const EdgeInsets.all(10),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
                                popUpModal.showOkOnlyDialog(
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

                  SizedBox(height: TSizes.mediumSpace),
                  const Text(
                    "Phân loại báo cáo",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: TSizes.mediumSpace),

                  /// Nhóm loại báo cáo
                  Obx(
                    () => DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Nhóm loại báo cáo ',
                            style: TextStyle(
                              color: dark ? Colors.white : TColors.darkerGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: const [
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
                        prefixIcon: Icon(Iconsax.category),
                      ),
                      value: reportController.selectedCategory.value,
                      items: reportController.reportCategories,
                      onChanged: (value) {
                        reportController.selectedCategory.value = value;
                        reportController.updateSubCategories(value);
                      },
                      validator: (value) => TValidator.validateDropdown(
                        "nhóm loại báo cáo",
                        value,
                      ),
                    ),
                  ),

                  const SizedBox(height: TSizes.mediumSpace),

                  /// Loại báo cáo chi tiết
                  Obx(
                    () => DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Loại báo cáo chi tiết ',
                            style: TextStyle(
                              color: dark ? Colors.white : TColors.darkerGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: const [
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
                      value: reportController.selectedSubCategory.value,
                      items: reportController.reportSubCategories,
                      onChanged: reportController.selectedCategory.value == null
                          ? null
                          : (value) =>
                                reportController.selectedSubCategory.value =
                                    value,
                      validator: (value) => TValidator.validateDropdown(
                        "loại báo cáo chi tiết",
                        value,
                      ),
                    ),
                  ),

                  const SizedBox(height: TSizes.mediumSpace),

                  /// Mức độ ưu tiên
                  Obx(
                    () => DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Mức độ ưu tiên ',
                            style: TextStyle(
                              color: dark ? Colors.white : TColors.darkerGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: const [
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
                        prefixIcon: Icon(Iconsax.warning_2),
                      ),
                      value: reportController.selectedPriority.value,
                      items: reportController.reportPriorities,
                      onChanged:
                          (reportController.selectedCategory.value != null &&
                              reportController.selectedSubCategory.value !=
                                  null)
                          ? (value) =>
                                reportController.selectedPriority.value = value
                          : null,
                      validator: (value) =>
                          TValidator.validateDropdown("mức độ ưu tiên", value),
                    ),
                  ),

                  SizedBox(height: TSizes.mediumSpace),
                  const Text(
                    "Thông tin vụ việc",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: TSizes.mediumSpace),

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
                            color: dark ? Colors.white : TColors.darkerGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: dark
                                ? TColors.white.withValues(alpha: 0.9)
                                : TColors.softGrey.withValues(alpha: 0.9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Iconsax.gps,
                                color: TColors.primary,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Chọn',
                                style: TextStyle(
                                  color: TColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.mediumSpace),
                  DateTimePickerField(
                    onChanged: (selectedDateTime) {
                      if (selectedDateTime != null) {
                        reportController.occurredAt.value = selectedDateTime
                            .toUtc()
                            .toIso8601String();
                      }
                    },
                  ),
                  const SizedBox(height: TSizes.mediumSpace),

                  /// Mô tả chi tiết
                  TextFormField(
                    controller: reportController.description,
                    maxLines: 5,
                    decoration: InputDecoration(
                      label: RichText(
                        text: TextSpan(
                          text: 'Mô tả chi tiết ',
                          style: TextStyle(
                            color: dark ? Colors.white : TColors.darkerGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                  const SizedBox(height: TSizes.mediumSpace),

                  /// Bằng chứng
                  RichText(
                    text: TextSpan(
                      text: 'Bằng chứng ',
                      style: TextStyle(
                        color: dark ? Colors.white : TColors.darkerGrey,
                        fontSize: 14,
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: dark
                                                ? TColors.lightDarkGrey
                                                : TColors.darkerGrey,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Tối đa ",
                                          style: TextStyle(
                                            fontSize: 12,
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
                                            fontSize: 12,
                                            color: dark
                                                ? TColors.white
                                                : TColors.darkGrey,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "1 video không quá 200MB",
                                          style: TextStyle(
                                            fontSize: 12,
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
                  const SizedBox(height: TSizes.mediumSpace),

                  /// Lưu ý
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
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
                                fontSize: 13,
                              ),
                              children: [
                                const TextSpan(
                                  text: '${TTexts.noticeTitle}\n',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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

                  const SizedBox(height: TSizes.mediumSpace),

                  /// Gửi báo cáo
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                      ),
                      onPressed: () {
                        popUpModal.showConfirmCancelDialog(
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
