import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';
import 'package:safe_city_mobile/utils/helpers/helper_functions.dart';

import 'features/personalization/screens/settings/settings.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: dark ? TColors.black : TColors.white,
          indicatorColor: dark
              ? TColors.white.withAlpha((0.1 * 255).round())
              : TColors.primary.withAlpha((0.1 * 255).round()),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.map_1), label: 'Bản đồ'),
            NavigationDestination(
              icon: Icon(Iconsax.warning_2),
              label: 'Trình báo',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.message_edit),
              label: 'Blog',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.location),
              label: 'Giám sát',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.setting),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    Container(color: Colors.red),
    Container(color: Colors.purple),
    Container(color: Colors.orange),
    Container(color: Colors.blue),
    const SettingsScreen(),
  ];
}
