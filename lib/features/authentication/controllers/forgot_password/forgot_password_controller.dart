import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../data/services/authentication/forgot_password_service.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/password_configuration/reset_password.dart';

class ForgetPasswordController extends GetxController {
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  Future<void> sendResetCode() async {
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

      if (!forgetPasswordFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final result = await ForgotPasswordService().sendForgotPasswordEmail(
        email.text,
      );
      TFullScreenLoader.stopLoading();

      if (result['success'] == true) {
        TLoaders.successSnackBar(
          title: 'Thành công',
          message:
              'Chúng tôi đã gửi mã OTP đến email của bạn. Vui lòng kiểm tra và sử dụng mã để đặt lại mật khẩu.',
        );
        Get.to(() => const ResetPassword());
      } else {
        TLoaders.errorSnackBar(title: 'Thất bại', message: result['message']);
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
