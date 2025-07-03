import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/hex_color_extension.dart';
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subscriptionController.activePackages.length,
            itemBuilder: (context, index) {
              final package = subscriptionController.activePackages[index];
              final baseColor = package.color.isNotEmpty
                  ? HexColor.fromHex(package.color)
                  : TColors.primary;
              final firstWord = package.name.split(' ').first;
              final darkerColor = baseColor.darken(0.25);

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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: TColors.white,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          subscriptionController.subscribeToPackage(package.id);
                        },
                        child: Text(
                          'Lấy $firstWord',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
