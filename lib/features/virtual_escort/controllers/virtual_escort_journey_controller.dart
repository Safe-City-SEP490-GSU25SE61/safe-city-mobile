
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VirtualEscortJourneyController extends GetxController {
  final virtualEscortJourneyFormKey = GlobalKey<FormState>();
  final destination = TextEditingController();
  final origin = TextEditingController();
  final estimatedTime = '15 minutes'.obs;
  final transportMode = 'Xe máy'.obs;
  final shareLocation = true.obs;
  final currentTab = 0.obs;

  void setTab(int index) => currentTab.value = index;

  void startEscort() {
    if (virtualEscortJourneyFormKey.currentState?.validate() ?? false) {
      debugPrint('Starting journey to: ${destination.text}');
      debugPrint('Time: ${estimatedTime.value}');
      debugPrint('Mode: ${transportMode.value}');
      debugPrint('Share Location: ${shareLocation.value}');
    }
  }

  void cancel() {
    Get.back();
  }

  void openAdvancedOptions() {
    setTab(1);
  }
}