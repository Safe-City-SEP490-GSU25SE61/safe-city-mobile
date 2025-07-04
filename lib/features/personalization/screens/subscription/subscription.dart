import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/hex_color_extension.dart';
import '../../controllers/profile/user_profile_controller.dart';
import '../../controllers/subcription/subcription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  final subscriptionController = Get.put(SubscriptionController());

  Future<void> _handleRefresh() async {
    await subscriptionController.fetchPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(
        title: Text('Gói đăng ký'),
        showCloseButton: false,
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.purple,
        child: Obx(() {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Iconsax.refresh, color: Colors.black, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Lịch sử',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              ...subscriptionController.activePackages.map((package) {
                final baseColor = package.color.isNotEmpty
                    ? HexColor.fromHex(package.color)
                    : TColors.primary;
                final firstWord = package.name.split(' ').first;
                final darkerColor = baseColor.darken(0.25);
                final user = Get.put(UserProfileController()).user.value;
                final isCurrentPackage =
                    user.currentSubscription.packageName == package.name;
                final shouldDisableButton = user.currentSubscription.isActive;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkerColor, baseColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${NumberFormat("#,###", "vi_VN").format(package.price)} ₫',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: ' / ${package.durationDays} ngày'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        package.description,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Material(
                        color: isCurrentPackage
                            ? Colors.grey.shade300
                            : shouldDisableButton
                            ? Colors.grey.shade100
                            : TColors.white,
                        borderRadius: BorderRadius.circular(24),
                        child: AbsorbPointer(
                          absorbing: shouldDisableButton || isCurrentPackage,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => subscriptionController
                                .subscribeToPackage(package.id),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(
                                isCurrentPackage
                                    ? user
                                          .currentSubscription
                                          .localizedRemainingTime
                                    : 'Lấy $firstWord',
                                style: TextStyle(
                                  color: shouldDisableButton || isCurrentPackage
                                      ? Colors.grey
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        }),
      ),
    );
  }
}
