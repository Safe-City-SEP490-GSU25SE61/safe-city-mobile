import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../data/services/authentication/forgot_password_service.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/login/login.dart';

class ResetPasswordController extends GetxController {
  final email = TextEditingController();
  final code = TextEditingController();
  final newPassword = TextEditingController();
  final hidePassword = true.obs;
  GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
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

      if (!resetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final result = await ForgotPasswordService().resetPassword(
        email: email.text,
        activationCode: code.text,
        newPassword: newPassword.text,
      );

      if (result['success'] == true) {
        TLoaders.successSnackBar(
          title: 'Thành công',
          message:
              'Mật khẩu của bạn đã được thay đổi thành công vui lòng đăng nhập lại',
        );
        Get.offAll(() => const LoginScreen());
      } else {
        TLoaders.errorSnackBar(
          title: 'Thay đổi mật khẩu thất bại',
          message: result['message'] ?? 'Đã xảy ra lỗi',
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
}
