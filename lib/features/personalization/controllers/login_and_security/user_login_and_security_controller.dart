import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safe_city_mobile/features/personalization/controllers/profile/user_profile_controller.dart';

import '../../../../data/services/personalization/user_login_and_security_service.dart';
import '../../../../data/services/personalization/user_profile_service.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/device_id_helper.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class UserLoginAndSecurityController extends GetxController {
  static UserLoginAndSecurityController get instance => Get.find();
  final _secureStorage = const FlutterSecureStorage();
  final _auth = LocalAuthentication();
  final RxBool isBiometricEnabled = false.obs;
  final userSecurityService = Get.put(UserLoginAndSecurityService());
  final userProfileService = Get.put(UserProfileService());

  @override
  void onInit() {
    loadBiometricPreference();
    super.onInit();
  }

  Future<void> loadBiometricPreference() async {
    final value = await _secureStorage.read(key: 'isBiometricLoginEnabled');
    isBiometricEnabled.value = value == 'true';
  }

  Future<void> toggleBiometricLogin(bool enable) async {
    try {
      if (!await _auth.canCheckBiometrics) {
        TLoaders.warningSnackBar(
          title: 'Xảy ra lỗi rồi',
          message: 'Thiết bị không hỗ trợ sinh trắc học.',
        );
        return;
      }

      if (!enable) {
        final didConfirm = await _auth.authenticate(
          localizedReason: 'Xác thực vân tay để tắt sinh trắc học',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!didConfirm) {
          TLoaders.warningSnackBar(title: '', message: 'Xác thực bị hủy.');
          return;
        }
      }

      if (enable) {
        final didConfirm = await _auth.authenticate(
          localizedReason: 'Xác thực vân tay để bật sinh trắc học',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );

        if (!didConfirm) {
          TLoaders.warningSnackBar(title: '', message: 'Xác thực bị hủy.');
          return;
        }
      }

      TFullScreenLoader.openLoadingDialog(
        'Đang xử lý...',
        TImages.loadingCircle,
      );

      final deviceId = await getDeviceIdHelper();
      final result = await userSecurityService.changeBiometricSettings(
        deviceId: deviceId,
        isBiometricEnabled: enable,
      );

      TFullScreenLoader.stopLoading();

      if (result['success']) {
        await _secureStorage.write(
          key: 'isBiometricLoginEnabled',
          value: enable.toString(),
        );

        await _secureStorage.write(key: 'deviceId', value: deviceId);

        isBiometricEnabled.value = enable;

        final userController = Get.put(UserProfileController());
        await userController.fetchUserProfile();

        TLoaders.successSnackBar(
          title: 'Thành công',
          message: enable ? 'Đã bật sinh trắc học.' : 'Đã tắt sinh trắc học.',
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Thất bại',
          message: result['message'] ?? 'Không thể cập nhật sinh trắc học.',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    }
  }

  Future<void> uploadIdentityImages({
    required File frontImage,
    required File backImage,
    required String email,
    required String phone,
  }) async {
    try {
      TFullScreenLoader.openLoadingDialog(
        'Đang cập nhật CCCD...',
        TImages.loadingCircle,
      );

      final deviceId = await getDeviceIdHelper();

      final result = await userProfileService.updateUserProfile(
        deviceId: deviceId,
        isBiometricEnabled: isBiometricEnabled.value,
        email: email,
        phone: phone,
        frontImage: frontImage,
        backImage: backImage,
      );

      TFullScreenLoader.stopLoading();

      if (result['success'] == true) {
        TLoaders.successSnackBar(
          title: 'Thành công',
          message: 'Cập nhật CCCD thành công.',
        );
        Get.back();
      } else {
          TLoaders.errorSnackBar(
            title: 'Lỗi',
            message: result['message'] ?? 'Đã xảy ra lỗi không xác định.',
          );

      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    }
  }
}
