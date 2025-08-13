import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safe_city_mobile/features/virtual_escort/models/virtual_escort_group_detail.dart';

import '../../../data/services/virtual_escort/virtual_escort_service.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../../utils/popups/loaders.dart';
import '../models/virtual_escort_group.dart';
import '../models/virtual_escort_pending_request.dart';

class VirtualEscortGroupController extends GetxController {
  static VirtualEscortGroupController get instance => Get.find();

  final policy = true.obs;
  final nameController = TextEditingController();
  final _service = VirtualEscortService();
  var groups = <EscortGroup>[].obs;
  var isLoadingGroup = false.obs;
  var groupDetail = Rxn<VirtualEscortGroupDetail>();
  var isLoadingGroupDetail = false.obs;
  final _auth = LocalAuthentication();
  final secureStorage = const FlutterSecureStorage();
  var pendingRequests = <VirtualEscortPendingRequest>[].obs;
  var isLoadingPending = false.obs;

  @override
  void onInit() {
    fetchMyGroups();
    super.onInit();
  }

  Future<void> createGroup() async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        return;
      }

      if (!policy.value) {
        TLoaders.warningSnackBar(
          title: "Thông báo",
          message: "Bạn phải đồng ý chia sẻ vị trí.",
        );
        return;
      }

      final name = nameController.text.trim();
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final result = await _service.createEscortGroup(name);
      Get.back();
      if (result["success"] == true) {
        FocusScope.of(Get.context!).unfocus();
        Navigator.pop(Get.context!);
        nameController.clear();
        TLoaders.successSnackBar(
          title: "Thành công",
          message: "Nhóm giám sát an toàn tạo thành công.",
        );
        await fetchMyGroups();
      } else {
        TLoaders.warningSnackBar(
          title: 'Không thể tạo nhóm!',
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

  Future<void> fetchMyGroups() async {
    try {
      isLoadingGroup.value = true;
      final result = await _service.getMyEscortGroups();
      if (result["success"] == true && result["data"] != null) {
        final data = result["data"] as List;
        groups.value = data.map((json) => EscortGroup.fromJson(json)).toList();
      } else {
        groups.clear();
        TLoaders.errorSnackBar(title: "Lỗi", message: "Không thể tải nhóm");
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching groups: $e");
      groups.clear();
    } finally {
      isLoadingGroup.value = false;
    }
  }

  Future<void> fetchGroupDetail(int groupId) async {
    try {
      isLoadingGroupDetail.value = true;
      final result = await _service.getEscortGroupDetail(groupId);

      if (result["success"] == true && result["data"] != null) {
        groupDetail.value = result["data"] as VirtualEscortGroupDetail;
      } else {
        groupDetail.value = null;
        TLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Không thể tải chi tiết nhóm",
        );
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching group detail: $e");
      groupDetail.value = null;
    } finally {
      isLoadingGroupDetail.value = false;
    }
  }

  Future<void> deleteGroup(String groupCode) async {
    try {
      final biometricEnabled = await secureStorage.read(
        key: 'is_biometric_login_enabled',
      );

      if (biometricEnabled != 'true') {
        TLoaders.warningSnackBar(
          title: 'Tính năng chưa được bật',
          message: 'Vui lòng bật tính năng sinh trắc học để xóa nhóm giám sát',
        );
        return;
      }

      final didConfirm = await _auth.authenticate(
        localizedReason: 'Xác thực vân tay để tắt sinh trắc học',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didConfirm) {
        TLoaders.warningSnackBar(
          title: 'Xác thực bị hủy',
          message: 'Xác thực sinh trắc học đã bị hủy vui lòng thử lại.',
        );
        return;
      }

      TFullScreenLoader.openLoadingDialog(
        "Đang xóa nhóm giám sát an toàn...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final result = await _service.deleteEscortGroup(groupCode);
      TFullScreenLoader.stopLoading();

      if (result["success"] == true) {
        Get.back();
        await fetchMyGroups();
        TLoaders.successSnackBar(
          title: "Thành công",
          message: "Nhóm đã được xóa thành công",
        );
      } else {
        TLoaders.errorSnackBar(
          title: "Lỗi",
          message: "Xóa nhóm thất bại, vui lòng thử lại sau",
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      if (kDebugMode) print("Error deleting group: $e");
      TLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Đã xảy ra lỗi khi xóa nhóm",
      );
    }
  }

  Future<void> joinGroupByCode(String code) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        Get.back();
        TLoaders.warningSnackBar(
          title: "Mất kết nối",
          message: "Vui lòng kiểm tra kết nối Internet của bạn",
        );
        return;
      }

      final result = await _service.joinEscortGroupByCode(code);
      Get.back();

      if (result["success"] == true) {
        await fetchMyGroups();
        Navigator.of(Get.overlayContext!).pop();
        TLoaders.successSnackBar(
          title: "Thành công",
          message: result["message"] ?? "Đã tham gia nhóm thành công",
        );
      } else {
        TLoaders.warningSnackBar(
          title: "Tham gia không thành công",
          message: result["message"] ?? "Vui lòng thử lại sau",
        );
      }
    } catch (e) {
      if (kDebugMode) print("Error joining group: $e");
      Get.back();
      TLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Đã xảy ra sự cố, vui lòng thử lại",
      );
    }
  }

  Future<void> fetchPendingRequests(int groupId) async {
    try {
      isLoadingPending.value = true;
      final result = await _service.getPendingRequests(groupId);
      if (result["success"] == true) {
        pendingRequests.value = result["data"] as List<VirtualEscortPendingRequest>;
      } else {
        pendingRequests.clear();
        TLoaders.errorSnackBar(title: "Lỗi", message: result["message"]);
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching pending requests: $e");
      pendingRequests.clear();
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> verifyMemberRequest({required int groupId, required int requestId, required bool approve,}) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        approve ? "Đang phê duyệt yêu cầu..." : "Đang từ chối yêu cầu...",
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final result = await _service.verifyMemberRequest(
        groupId: groupId,
        requestId: requestId,
        approve: approve,
      );

      TFullScreenLoader.stopLoading();

      if (result["success"] == true) {
        pendingRequests.removeWhere((req) => req.id == requestId);
        await fetchGroupDetail(groupId);
        await fetchMyGroups();
        TLoaders.successSnackBar(
          title: "Thành công",
          message: result["message"] ?? "Yêu cầu đã được xử lý",
        );
      } else {
        TLoaders.errorSnackBar(
          title: "Lỗi",
          message: result["message"] ?? "Không thể xử lý yêu cầu",
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      if (kDebugMode) print("Error verifying request: $e");
      TLoaders.errorSnackBar(
        title: "Lỗi",
        message: "Đã xảy ra lỗi khi xử lý yêu cầu",
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
