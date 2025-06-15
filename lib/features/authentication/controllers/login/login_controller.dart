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
import '../../screens/register/verify_email.dart';

class LoginController extends GetxController {
  final quickLogin = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  final secureStorage = const FlutterSecureStorage();
  final biometricHelper = BiometricHelper();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    email.text = localStorage.read("biometric_login_email") ?? '';
    password.text = localStorage.read("biometric_login_password") ?? '';
    super.onInit();
  }

  Future<void> handleFingerprintLogin() async {
    final biometricEnabled = await secureStorage.read(key: 'biometric_login_status');
    if (biometricEnabled != 'true') {
      TLoaders.warningSnackBar(
        title: 'Tính năng chưa được bật',
        message: 'Vui lòng đăng nhập bằng Email và Mật khẩu',
      );
      return;
    }

    final authenticated = await biometricHelper.authenticateWithBiometrics();
    if (authenticated) {
      final savedEmail = localStorage.read("biometric_login_email");
      final savedPassword = localStorage.read("biometric_login_password");

      if (savedEmail == null || savedPassword == null) {
        TLoaders.errorSnackBar(
          title: 'Không tìm thấy tài khoản',
          message: 'Vui lòng đăng nhập lại bằng Email và Mật khẩu',
        );
        return;
      }

      email.text = savedEmail;
      password.text = savedPassword;

      TLoaders.successSnackBar(
        title: 'Xác thực thành công',
        message: 'Email và mật khẩu đã được tải',
      );

    } else {
      TLoaders.errorSnackBar(
        title: 'Xác thực thất bại',
        message: 'Không thể xác thực vân tay',
      );
    }
  }


  Future<void> emailAndPasswordSignIn() async {
    try {
      //start loading
      TFullScreenLoader.openLoadingDialog(
        'Đang xử lí chờ xíu...',
        TImages.screenLoadingSparkle2,
      );

      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      //form validation
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
        final accessToken = result['data']['data']?['access_token'] ?? "";
        final refreshToken = result['data']['data']?['refresh_token'] ?? "";

        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'refresh_token', value: refreshToken);

        Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
        String? userRole = decodedToken['role'];
        String? userId = decodedToken['sub'];
        await secureStorage.write(key: 'user_id', value: userId);

        if (userRole == 'Customer') {
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

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
