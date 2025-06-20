import 'package:flutter/foundation.dart';
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

  Future<void> logout() async {
    try {
      //start loading
      TFullScreenLoader.openLoadingDialog(
        'Đang xử lí chờ xíu...',
        TImages.screenLoadingSparkle3,
      );

      //check internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      TFullScreenLoader.stopLoading();

      await storage.delete(key: 'access_token');
      await storage.delete(key: 'refresh_token');
      await storage.delete(key: 'user_id');

      TLoaders.successSnackBar(
        title: 'Đăng xuất thành công',
        message: 'Bạn đã đăng xuất thành công',
      );
      Get.offAll(() => const LoginScreen());
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
