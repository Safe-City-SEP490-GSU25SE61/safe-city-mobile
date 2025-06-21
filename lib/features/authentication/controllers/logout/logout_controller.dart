import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../screens/login/login.dart';

class LogoutController extends GetxController {
  var client = http.Client();
  final storage = const FlutterSecureStorage();
  final String? apiConnection = dotenv.env['API_DEPLOYMENT_URL'];

  Future<void> logout() async {
    try {
      //start loading
      TFullScreenLoader.openLoadingDialog(
        'Đang xử lí chờ xíu...',
        TImages.loadingCircle,
      );

      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      final refreshToken = await storage.read(key: 'refresh_token');
      final response = await client
          .post(
            Uri.parse('${apiConnection}auth/logout'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      TFullScreenLoader.stopLoading();

      if (kDebugMode) {
        print('Logout response (${response.statusCode}): ${response.body}');
      }

      if (response.statusCode == 200) {
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
        await storage.delete(key: 'user_id');

        TLoaders.successSnackBar(
          title: 'Đăng xuất thành công',
          message: 'Bạn đã đăng xuất thành công',
        );

        // Navigate to login screen
        Get.offAll(() => const LoginScreen());
      } else {
        final responseData = jsonDecode(response.body);
        TLoaders.warningSnackBar(
          title: 'Đăng xuất thất bại',
          message: responseData['message'] ?? 'Đã xảy ra lỗi khi đăng xuất',
        );
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      TLoaders.errorSnackBar(
        title: 'Đăng xuất thất bại',
        message: 'Đã xảy ra sự cố không xác định, vui lòng thử lại sau',
      );
    }
  }
}
