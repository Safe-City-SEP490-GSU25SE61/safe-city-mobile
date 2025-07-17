import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/subcription/subcription_controller.dart';

class SubscriptionHistoryScreen extends StatelessWidget {
  SubscriptionHistoryScreen({super.key});

  final controller = Get.put(SubscriptionController());

  Future<void> _handleRefresh() async {
    await controller.fetchPaymentHistory();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: const TAppBar(
        title: Text('Lịch sử đăng ký gói'),
        showCloseButton: false,
        showBackArrow: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: TColors.primary),
            );
          }

          if (controller.history.isEmpty) {
            return const Center(child: Text("Không có lịch sử đăng ký"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.history.length,
            itemBuilder: (context, index) {
              final item = controller.history[index];
              return Card(
                color: dark ? TColors.white : TColors.lightGrey,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    item.packageName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: "Mã đơn: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: item.orderCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: TSizes.xs),
                      RichText(
                        text: TextSpan(
                          text: "Phương thức: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: item.paymentMethod,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: TSizes.xs),
                      RichText(
                        text: TextSpan(
                          text: "Trạng thái: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: item.status,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: TSizes.xs),
                      RichText(
                        text: TextSpan(
                          text: "Thời gian: ",
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(
                              text: item.paidAt,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: '₫',
                    ).format(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TColors.success,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
