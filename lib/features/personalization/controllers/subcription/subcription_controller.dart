import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../../../data/services/personalization/subcription_service.dart';
import '../../models/subcription_package_model.dart';
import '../../screens/subscription/subscription_web_view_payment.dart';

class SubscriptionController extends GetxController {
  static SubscriptionController get instance => Get.find();
  final subscriptionService = Get.put(SubscriptionService());
  final secureStorage = const FlutterSecureStorage();
  var isLoading = false.obs;
  var activePackages = <SubscriptionPackageModel>[].obs;

  @override
  void onInit() {
    fetchPackages();
    super.onInit();
  }

  Future<void> fetchPackages() async {
    try {
      isLoading(true);
      final packages = await subscriptionService.fetchActivePackages();
      activePackages.assignAll(packages);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading packages: $e');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> subscribeToPackage(int packageId) async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken == null) throw Exception('Token missing');

      final checkoutUrl = await subscriptionService.createSubscription(packageId, accessToken);
      if (checkoutUrl != null) {
        Get.to(() => SubscriptionWebViewPayment(url: checkoutUrl));
      } else {
        Get.snackbar("Lỗi", "Không thể lấy link thanh toán");
      }
    } catch (e) {
      if (kDebugMode) {
        print('Subscription error: $e');
      }
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi đăng ký gói");
    }
  }
}
