import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/incident_report/incident_report_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/media_helper.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/incident_report_model.dart';
import '../models/report_history_model.dart';

class IncidentReportController extends GetxController {
  final images = <PlatformFile>[].obs;
  final video = Rxn<PlatformFile>();
  final address = TextEditingController();
  final searchController = TextEditingController();
  final lat = 0.0.obs;
  final lng = 0.0.obs;
  final occurredAt = ''.obs;
  final description = TextEditingController();
  final isAnonymous = false.obs;
  final selectedCategory = RxnString();
  final selectedSubCategory = RxnString();
  final selectedPriority = RxnString();
  final searchCommuneName = ''.obs;
  final selectedFilterSort = Rxn<ReportSort>();
  final selectedFilterPriority = Rxn<ReportPriority>();

  List<ReportSort> get sortOptions => ReportSort.values;

  List<ReportPriority> get priorityOptions => ReportPriority.values;

  GlobalKey<FormState> incidentReportFormKey = GlobalKey<FormState>();

  var isLoadingReportHistory = false.obs;
  var reportHistory = <ReportHistoryModel>[].obs;
  final selectedStatus = Rxn<ReportStatus>();
  final selectedRange = Rxn<ReportRange>();
  final reportCategories = <DropdownMenuItem<String>>[].obs;
  final reportSubCategories = <DropdownMenuItem<String>>[].obs;
  final reportPriorities = <DropdownMenuItem<String>>[].obs;
  Map<String, List<Map<String, String>>> categoryToSubMap = {};

  List<ReportStatus> get statusOptions => ReportStatus.values;

  List<ReportRange> get rangeOptions => ReportRange.values;

  @override
  void onInit() {
    super.onInit();
    fetchMetadata();
    fetchReportHistory();
  }

  void pickMedia() async {
    final result = await MediaHelper.pickMedia();
    if (result != null) {
      images.value = result['images'] ?? [];
      video.value = result['video'];
    }
  }

  void clearReportForm() {
    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedPriority.value = null;
    address.clear();
    lat.value = 0.0;
    lng.value = 0.0;
    occurredAt.value = '';
    description.clear();
    isAnonymous.value = false;
    images.clear();
    video.value = null;
  }

  Future<void> submitReport() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Đang gửi báo cáo...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!incidentReportFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final report = IncidentReportModel(
        isAnonymous: isAnonymous.value,
        lat: lat.value,
        lng: lng.value,
        address: address.text.trim(),
        occurredAt: occurredAt.value,
        type: selectedCategory.value!,
        subCategory: selectedSubCategory.value!,
        description: description.text.trim(),
        priorityLevel: selectedPriority.value!,
      );

      final result = await IncidentReportService.submitIncidentReport(
        model: report,
        images: images,
        video: video.value,
      );

      TFullScreenLoader.stopLoading();
      FocusScope.of(Get.context!).unfocus();

      if (result['success']) {
        clearReportForm();
        Get.back();
        TLoaders.successSnackBar(
          title: "Thành công",
          message: "Báo cáo đã được gửi.",
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Xảy ra lỗi rồi!',
          message:
              result['message'] ??
              'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi rồi!',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    }
  }

  Future<void> fetchReportHistory() async {
    try {
      isLoadingReportHistory(true);

      final range = selectedRange.value?.value;
      final status = selectedStatus.value?.value;
      final sort = selectedFilterSort.value?.value;
      final priority = selectedFilterPriority.value?.value;
      final commune = searchCommuneName.value.isNotEmpty
          ? searchCommuneName.value
          : null;

      final result = await IncidentReportService().fetchReportHistory(
        range: range?.isNotEmpty == true ? range : null,
        status: status?.isNotEmpty == true ? status : null,
        sort: sort?.isNotEmpty == true ? sort : null,
        priority: priority?.isNotEmpty == true ? priority : null,
        communeName: commune,
      );

      reportHistory.assignAll(result);
    } catch (e) {
      if (kDebugMode) print('Fetch error: $e');
    } finally {
      isLoadingReportHistory(false);
    }
  }

  void updateFilters({
    ReportRange? range,
    ReportStatus? status,
    ReportSort? sort,
    ReportPriority? priority,
    String? communeName,
  }) {
    selectedRange.value = range;
    selectedStatus.value = status;
    selectedFilterSort.value = sort;
    selectedFilterPriority.value = priority;
    if (communeName != null) searchCommuneName.value = communeName;
  }

  Future<void> fetchMetadata() async {
    try {
      final metadata = await IncidentReportService().fetchReportMetadata();

      final types = metadata['types'] as List;
      reportCategories.assignAll(
        types.map<DropdownMenuItem<String>>((type) {
          final value = type['value'].toString();
          final displayName = type['displayName'].toString();

          final subCategories = type['subCategories'] as List;
          categoryToSubMap[value] = subCategories.map<Map<String, String>>((
            sub,
          ) {
            return {
              'value': sub['value'].toString(),
              'displayName': sub['displayName'].toString(),
            };
          }).toList();

          return DropdownMenuItem<String>(
            value: value,
            child: Text(displayName),
          );
        }).toList(),
      );

      final priorities = metadata['priorityLevels'] as List;
      reportPriorities.assignAll(
        priorities.map<DropdownMenuItem<String>>((level) {
          return DropdownMenuItem<String>(
            value: level['value'].toString(),
            child: Text(level['displayName'].toString()),
          );
        }).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching metadata: $e');
      }
    }
  }

  void updateSubCategories(String? categoryValue) {
    selectedSubCategory.value = null;
    selectedPriority.value = null;
    if (categoryValue == null) {
      reportSubCategories.clear();
      return;
    }

    final subList = categoryToSubMap[categoryValue] ?? [];
    reportSubCategories.assignAll(
      subList.map((sub) {
        return DropdownMenuItem<String>(
          value: sub['value'],
          child: Text(sub['displayName']!),
        );
      }).toList(),
    );
  }

  Future<bool> cancelReport(String reportId, String message) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        'Đang hủy báo cáo...',
        TImages.loadingCircle,
      );

      final result = await IncidentReportService().cancelReport(
        reportId,
        message,
      );

      TFullScreenLoader.stopLoading();

      if (result['success']) {
        TLoaders.successSnackBar(
          title: 'Thành công',
          message: result['message'],
        );
        fetchReportHistory();
        return true;
      } else {
        TLoaders.warningSnackBar(title: 'Thất bại', message: result['message']);
        return false;
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi', message: e.toString());
      return false;
    }
  }
}
