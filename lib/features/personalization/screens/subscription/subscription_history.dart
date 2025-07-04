import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
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
      appBar: AppBar(
        title: const Text("Lịch sử đăng ký"),
        backgroundColor: Colors.transparent,
        foregroundColor: dark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: Obx(() {
          if (controller.history.isEmpty) {
            return const Center(child: Text("Không có lịch sử đăng ký"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: controller.history.length,
            itemBuilder: (context, index) {
              final item = controller.history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(item.packageName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Mã đơn: ${item.orderCode}"),
                      Text("Phương thức: ${item.paymentMethod}"),
                      Text("Trạng thái: ${item.status}"),
                      Text("Thời gian thanh toán: ${item.paidAt}"),
                    ],
                  ),
                  trailing: Text(
                    NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: '₫',
                    ).format(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
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
