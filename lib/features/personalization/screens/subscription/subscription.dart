import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:safe_city_mobile/features/personalization/screens/subscription/subscription_history.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/hex_color_extension.dart';
import '../../controllers/profile/user_profile_controller.dart';
import '../../controllers/subcription/subcription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  final subscriptionController = Get.put(SubscriptionController());
  final userController = Get.put(UserProfileController());

  Future<void> _handleRefresh() async {
    await subscriptionController.fetchPackages();
    await userController.fetchUserProfile();
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
                  onTap: () {
                    Get.to(() => SubscriptionHistoryScreen());
                  },
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
                final darkerColor = baseColor.darken(0.35);
                final user = userController.user.value;
                final isCurrentPackage = user.currentSubscription.packageName == package.name;
                final isExpired = user.currentSubscription.remainingTime == '0d 0h 0m';
                final shouldDisableButton = !isExpired;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        baseColor,
                        darkerColor,
                      ],
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
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: '${NumberFormat("#,###", "vi_VN").format(package.price)} ₫',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            TextSpan(
                              text: ' / ${package.durationDays} ngày',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Gói này gồm",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          package.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
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
                          absorbing: shouldDisableButton,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => subscriptionController.subscribeToPackage(package.id),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Text(
                                isCurrentPackage
                                    ? user.currentSubscription.localizedRemainingTime
                                    : 'Lấy ${package.name}',
                                style: TextStyle(
                                  color: shouldDisableButton
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
              }),
            ],
          );
        }),
      ),
    );
  }
}
