import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../../../data/services/authentication/authentication_service.dart';
import '../../../../navigation_dart.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/biometric_helper.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/login/login.dart';

class LoginController extends GetxController {
  final rememberMe = false.obs;
  final quickLogin = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final secureStorage = const FlutterSecureStorage();
  final biometricHelper = BiometricHelper();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  Future<void> handleFingerprintLogin() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        'Đang xử lí chờ xíu...',
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final biometricEnabled = await secureStorage.read(
        key: 'is_biometric_login_enabled',
      );

      if (biometricEnabled != 'true') {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Tính năng chưa được bật',
          message: 'Vui lòng đăng nhập bằng Email và Mật khẩu',
        );
        return;
      }

      final authenticated = await biometricHelper.authenticateWithBiometrics();
      if (!authenticated) {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Xác thực bị hủy bỏ',
          message: 'Không thể xác thực vân tay',
        );
        return;
      }

      final savedEmail = await secureStorage.read(key: "biometric_login_email");
      final savedPassword = await secureStorage.read(
        key: "biometric_login_password",
      );
      final deviceId = await secureStorage.read(key: 'device_id');

      if (savedEmail == null || savedPassword == null || deviceId == null) {
        TLoaders.errorSnackBar(
          title: 'Thông tin đăng nhập không đầy đủ',
          message: 'Vui lòng đăng nhập lại bằng Email và Mật khẩu',
        );
        return;
      }

      final result = await AuthenticationService().handleBiometricLogin(
        email: savedEmail,
        password: savedPassword,
        deviceId: deviceId,
      );
      TFullScreenLoader.stopLoading();

      if (result['success']) {
        final accessToken = result['data']['data']?['accessToken'] ?? "";
        final refreshToken = result['data']['data']?['refreshToken'] ?? "";

        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'refresh_token', value: refreshToken);

        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        String? userRole = decodedToken['role'];
        String? userId = decodedToken['sub'];

        await secureStorage.write(key: 'user_id', value: userId);

        if (userRole == 'Citizen') {
          TLoaders.successSnackBar(
            title: 'Chào mừng quay trở lại!',
            message: 'Rất nhiều ưu đãi đang chờ đón bạn',
          );
          Get.offAll(() => const NavigationMenu());
        } else {
          TLoaders.errorSnackBar(
            title: 'Không hợp lệ',
            message: 'Vai trò người dùng không hợp lệ',
          );
        }
      } else if (result['unauthorized'] == true &&
          result['message'] ==
              "You haven't enabled biometrics on this device yet.") {
        TFullScreenLoader.stopLoading();
        TLoaders.warningSnackBar(
          title: 'Thiết bị chưa được kích hoạt',
          message: 'Bạn chưa bật đăng nhập vân tay cho thiết bị này.',
        );
        Get.offAll(() => const LoginScreen());
      } else {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
          title: 'Đăng nhập thất bại',
          message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau.',
        );
        Get.offAll(() => const LoginScreen());
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
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> emailAndPasswordSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        'Đang xử lí chờ xíu...',
        TImages.loadingCircle,
      );

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final result = await AuthenticationService().handleSignIn(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      TFullScreenLoader.stopLoading();
      FocusScope.of(Get.context!).unfocus();

      if (result['success'] == true) {
        final accessToken = result['data']['data']?['accessToken'] ?? "";
        final refreshToken = result['data']['data']?['refreshToken'] ?? "";

        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'refresh_token', value: refreshToken);

        final isBiometricEnabled = localStorage.read(
          "is_biometric_login_enabled",
        );
        if (isBiometricEnabled == null ||
            isBiometricEnabled.toString().trim().isEmpty) {
          await secureStorage.write(
            key: 'biometric_login_email',
            value: email.text.trim(),
          );
          await secureStorage.write(
            key: 'biometric_login_password',
            value: password.text.trim(),
          );
        }

        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        String? userRole = decodedToken['role'];
        String? userId = decodedToken['sub'];
        await secureStorage.write(key: 'user_id', value: userId);

        if (userRole == 'Citizen') {
          TLoaders.successSnackBar(
            title: 'Chào mừng quay trở lại!',
            message: 'Rất nhiều ưu đãi đang chờ đón bạn',
          );
          Get.offAll(() => const NavigationMenu());
        }
      } else if (result['success'] == false) {
        TLoaders.warningSnackBar(
          title: 'Xác thực không thành công',
          message: ' Email/Mật khẩu không chính xác',
        );
        return;
      } else if (result['accountDisabled'] == true) {
        // Get.offAll(() => const VerifyEmailScreen());
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
}
