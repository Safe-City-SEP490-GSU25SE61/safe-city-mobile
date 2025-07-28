import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/services/community_blog/blog_filter_service.dart';

class BlogFilterController extends GetxController {
  static BlogFilterController get instance => Get.find();

  final BlogFilterService service = BlogFilterService();

  RxList<String> provinces = <String>[].obs;
  RxList<String> communes = <String>[].obs;

  RxString selectedProvince = ''.obs;
  RxString selectedCommune = ''.obs;

  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProvinces();
  }

  Future<void> fetchProvinces() async {
    try {
      loading.value = true;
      provinces.value = await service.getProvinces();

      if (provinces.isNotEmpty) {
        selectedProvince.value = provinces.first;
        await fetchCommunesByProvince(provinces.first);
      }
    } catch (e) {
      if (kDebugMode) print('Error loading provinces: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchCommunesByProvince(String provinceName) async {
    try {
      loading.value = true;
      selectedProvince.value = provinceName;

      final index = provinces.indexOf(provinceName);
      if (index != -1) {
        communes.value = await service.getCommunesByProvinceId(index + 1);

        if (communes.isNotEmpty) {
          if (!communes.contains(selectedCommune.value)) {
            selectedCommune.value = communes.first;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error loading communes: $e');
    } finally {
      loading.value = false;
    }
  }

  void resetFilters() {
    selectedProvince.value = '';
    selectedCommune.value = '';
    communes.clear();
  }
}
