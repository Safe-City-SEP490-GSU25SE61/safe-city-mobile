
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/virtual_escort/virtual_escort_service.dart';

class VirtualEscortJourneyController extends GetxController {
  static VirtualEscortJourneyController get instance => Get.find();
  final virtualEscortJourneyFormKey = GlobalKey<FormState>();
  final destination = TextEditingController();
  final origin = TextEditingController();
  final estimatedTime = '15 minutes'.obs;
  final transportMode = 'Xe máy'.obs;
  final shareLocation = true.obs;
  final currentTab = 0.obs;
  final escortService = VirtualEscortService();

  void setTab(int index) => currentTab.value = index;

  void startEscort() {
    if (virtualEscortJourneyFormKey.currentState?.validate() ?? false) {
      debugPrint('Starting journey to: ${destination.text}');
      debugPrint('Time: ${estimatedTime.value}');
      debugPrint('Mode: ${transportMode.value}');
      debugPrint('Share Location: ${shareLocation.value}');
    }
  }

  Future<void> initConnection({required bool isLeader}) async {
    await escortService.initSignalR(isLeader: isLeader);
  }

  void cancel() {
    Get.back();
  }

  void openAdvancedOptions() {
    setTab(1);
  }
}