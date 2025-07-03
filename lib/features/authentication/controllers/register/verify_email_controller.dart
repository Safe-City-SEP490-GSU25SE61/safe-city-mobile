import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../data/services/authentication/http_interceptor.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/login/login.dart';

class VerifyEmailController extends GetxController {
  var client = HttpInterceptor();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];
  final storage = const FlutterSecureStorage();
  var otp = List<String>.filled(6, "").obs;

  @override
  void onInit() {
    setTimerForAutoRedirect();
    super.onInit();
  }

  void verifyEmail() async {
    final token = otp.join('');
    if (token.length != 6) {
      TLoaders.warningSnackBar(
        title: 'OTP không hợp lệ',
        message: 'Vui lòng nhập mã OTP hợp lệ',
      );
      return;
    }

    try {
      TFullScreenLoader.openLoadingDialog(
          'Đang xử lí chờ xíu...', TImages.loadingCircle);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      String? email = await storage.read(key: "user_email_verification");
      final response = await client
          .post(
        Uri.parse('${apiConnection}auth/verify-account'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
        body: jsonEncode({
          "email": email,
          "otp": token,
        }),
      )
          .timeout(const Duration(seconds: 10));

      TFullScreenLoader.stopLoading();

      if (response.statusCode == 200) {
        TFullScreenLoader.stopLoading();
        Get.to(() => SuccessScreen(
            image: TImages.emailAccountSuccess,
            title: TTexts.yourAccountCreatedTitle,
            subTitle: TTexts.yourAccountCreatedSubTitle,
            onPressed: () => Get.offAll(const LoginScreen())));

        await storage.delete(key: "user_email_verification");
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        if (responseData['message'] == 'Account not found.') {
          TLoaders.errorSnackBar(
            title: 'Tài khoản không tồn tại',
            message:
            'Không tìm thấy tài khoản với email này. Vui lòng kiểm tra lại.',
          );
          if (kDebugMode) {
            print('Verify failed: ${response.body}');
          }
        } else if (response.statusCode == 401) {
          if (responseData['message'] == 'Incorrect OTP. Please try again.') {
            TLoaders.errorSnackBar(
              title: 'OTP không chính xác',
              message: 'Mã OTP không đúng. Vui lòng thử lại.',
            );
          } else {
            TLoaders.warningSnackBar(
              title: 'Lỗi máy chủ',
              message: 'Đã xảy ra lỗi không xác định. Vui lòng thử lại sau.',
            );
            if (kDebugMode) {
              print('Verify failed: ${response.body}');
            }
          }
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Xảy ra lỗi rồi!', message: e.toString());
    }
  }

  void setTimerForAutoRedirect() {
    Timer.periodic(const Duration(seconds: 1), (timer) {});
  }
}
