import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  final type = RxnString();
  final address = TextEditingController();
  final lat = 0.0.obs;
  final lng = 0.0.obs;
  final occurredAt = ''.obs;
  final description = TextEditingController();
  final isAnonymous = false.obs;
  GlobalKey<FormState> incidentReportFormKey = GlobalKey<FormState>();

  var isLoadingReportHistory = false.obs;
  var reportHistory = <ReportHistoryModel>[].obs;
  final selectedStatus = Rxn<ReportStatus>();
  final selectedRange = Rxn<ReportRange>();

  List<ReportStatus> get statusOptions => ReportStatus.values;

  List<ReportRange> get rangeOptions => ReportRange.values;

  @override
  void onInit() {
    fetchReportHistory();
    super.onInit();
  }

  void pickMedia() async {
    final result = await MediaHelper.pickMedia();
    if (result != null) {
      images.value = result['images'] ?? [];
      video.value = result['video'];
    }
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
        type: type.value!,
        description: description.text.trim(),
      );

      final result = await IncidentReportService.submitIncidentReport(
        model: report,
        images: images,
        video: video.value,
      );

      TFullScreenLoader.stopLoading();
      FocusScope.of(Get.context!).unfocus();

      if (result['success']) {
        images.clear();
        video.value = null;
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
      final String? range = selectedRange.value?.value;
      final String? status = selectedStatus.value?.value;

      final result = await IncidentReportService().fetchReportHistory(
        range: range?.isNotEmpty == true ? range : null,
        status: status?.isNotEmpty == true ? status : null,
      );
      reportHistory.assignAll(result);
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Tải lịch sử không thành công',
        message: 'Không thể tải lịch sử báo cáo',
      );
      if (kDebugMode) print('Fetch error: $e');
    } finally {
      isLoadingReportHistory(false);
    }
  }

  void updateFilters({ReportRange? range, ReportStatus? status}) {
    if (range != selectedRange.value) selectedRange.value = range;
    if (status != selectedStatus.value) selectedStatus.value = status;
    fetchReportHistory();
  }
}
