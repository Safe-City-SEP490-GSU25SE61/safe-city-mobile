import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/popups/full_screen_loader.dart';
import '../../../../../utils/popups/loaders.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../data/services/personalization/user_profile_service.dart';
import '../../../../utils/helpers/network_manager.dart';

import '../../models/achivement_model.dart';
import '../../models/user_profile_model.dart';
import '../../screens/profile/profile.dart';

class UserProfileController extends GetxController {
  static UserProfileController get instance => Get.find();
  Rx<UserProfileModel> user = UserProfileModel.empty().obs;
  var achievements = <AchievementModel>[].obs;
  final userProfileService = Get.put(UserProfileService());
  final email = TextEditingController();
  final phone = TextEditingController();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  var userUpdateProfile = {}.obs;
  final profileLoading = false.obs;
  final imageUploading = false.obs;
  final hideOldPassword = true.obs;
  final hideNewPassword = true.obs;
  final showFullProfile = false.obs;
  final secureStorage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchAchievements();
  }

  Future<void> fetchUserProfile() async {
    try {
      profileLoading.value = true;
      final user = await userProfileService.getUserProfile();
      this.user(user);
      profileLoading.value = false;
    } catch (e) {
      user(UserProfileModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (!profileFormKey.currentState!.validate()) return;

    TFullScreenLoader.openLoadingDialog('Đang xử lý...', TImages.loadingCircle);

    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TFullScreenLoader.stopLoading();
      return;
    }

    final result = await userProfileService.changePassword(
      oldPassword.text.trim(),
      newPassword.text.trim(),
    );

    TFullScreenLoader.stopLoading();

    if (result['success']) {
      TLoaders.successSnackBar(
        title: 'Thành công',
        message: 'Đổi mật khẩu thành công!',
      );
      Get.to(ProfileScreen());
    } else {
      final message =
          result['errors']?['OldPassword']?.join('\n') ?? result['message'];
      TLoaders.errorSnackBar(title: 'Thất bại', message: message);
    }
  }

  Future<void> handleImageProfileUpload() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 2000,
        maxWidth: 2000,
      );

      if (image != null) {
        imageUploading.value = true;

        final result = await UserProfileService().updateUserProfilePicture(
          image,
        );

        if (result['success'] == true) {
          await fetchUserProfile();
          TLoaders.successSnackBar(
            title: 'Thành công',
            message: 'Cập nhật ảnh đại diện thành công',
          );
        } else {
          TLoaders.errorSnackBar(
            title: 'Xảy ra lỗi rồi!',
            message: result['message'] ?? 'Không thể cập nhật ảnh đại diện',
          );
        }
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi rồi!',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    } finally {
      imageUploading.value = false;
    }
  }

  Future<void> unlockFullProfile() async {
    try {
      final biometricEnabled = await secureStorage.read(
        key: 'is_biometric_login_enabled',
      );

      if (biometricEnabled != 'true') {
        TLoaders.warningSnackBar(
          title: 'Tính năng chưa được bật',
          message: 'Vui lòng bật tính năng sinh trắc học để xem chi tiết hồ sơ',
        );
        return;
      }

      final auth = LocalAuthentication();
      final didConfirm = await auth.authenticate(
        localizedReason: 'Xác thực vân tay để xem toàn bộ thông tin cá nhân',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didConfirm) {
        showFullProfile.value = true;
      } else {
        showFullProfile.value = false;
        TLoaders.warningSnackBar(
          title: 'Xác thực thất bại',
          message: 'Bạn cần xác thực để xem thông tin đầy đủ.',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Xảy ra lỗi rồi!',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    }
  }

  Future<void> updateEmailAndPhoneOnly() async {
    if (!profileFormKey.currentState!.validate()) return;

    final biometricEnabled = await secureStorage.read(
      key: 'is_biometric_login_enabled',
    );

    if (biometricEnabled != 'true') {
      TLoaders.warningSnackBar(
        title: 'Tính năng chưa được bật',
        message: 'Vui lòng bật tính năng sinh trắc học để cập nhật thông tin',
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
      TLoaders.warningSnackBar(title: 'Xác thực bị hủy', message: 'Xác thực sinh trắc học đã bị hủy vui lòng thử lại.');
      return;
    }

    TFullScreenLoader.openLoadingDialog(
      'Đang cập nhật thông tin...',
      TImages.loadingCircle,
    );

    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TFullScreenLoader.stopLoading();
      return;
    }

    try {
      final deviceId = await secureStorage.read(key: 'device_id');
      final result = await userProfileService.updateUserProfile(
        deviceId: deviceId!,
        isBiometricEnabled: true,
        email: email.text.trim(),
        phone: phone.text.trim(),
        frontImage: null,
        backImage: null,
      );

      TFullScreenLoader.stopLoading();

      if (result['success'] == true) {
        TLoaders.successSnackBar(
          title: 'Thành công',
          message: "Cập nhật thông tin thành công",
        );
        await fetchUserProfile();
        Get.back();
      } else {
        TLoaders.errorSnackBar(
          title: 'Thất bại',
          message: result['message'] ?? 'Không thể cập nhật thông tin',
        );

        if (result.containsKey("errors")) {
          final errors = result['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            TLoaders.warningSnackBar(title: key, message: value.toString());
          });
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi hệ thống', message: e.toString());
    }
  }

  Future<void> updateIdentityCardOnly({
    required File frontImage,
    required File backImage,
  }) async {
    TFullScreenLoader.openLoadingDialog(
      'Đang tải ảnh CCCD...',
      TImages.loadingCircle,
    );

    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TFullScreenLoader.stopLoading();
      return;
    }

    try {
      final deviceId = await secureStorage.read(key: 'device_id');
      final result = await userProfileService.updateUserProfile(
        deviceId: deviceId!,
        isBiometricEnabled: true,
        email: user.value.email,
        phone: user.value.phone,
        frontImage: frontImage,
        backImage: backImage,
      );

      TFullScreenLoader.stopLoading();

      if (result['success'] == true) {
        TLoaders.successSnackBar(
          title: 'Thành công',
          message: "Cập nhật thông tin CCCD thành công",
        );
        await fetchUserProfile();
      } else {
        TLoaders.errorSnackBar(
          title: 'Xảy ra lỗi xác thực',
          message: 'Hình ảnh CCCD chưa chính xác hoặc sai thứ tự, vui lòng thử lại',
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi hệ thống', message: e.toString());
    }
  }

  Future<void> fetchAchievements() async {
    try {
      final token = await secureStorage.read(key: 'access_token');
      if (token == null) return;

      final list = await userProfileService.fetchAchievements(token);
      achievements.assignAll(list);
    } catch (e) {
      if (kDebugMode) print('Failed to fetch achievements: $e');
    }
  }
}
