import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../navigation_dart.dart';
import '../../../../utils/constants/image_strings.dart';

class PaymentCancelScreen extends StatelessWidget {
  const PaymentCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: const Text('Thanh toán thất bại'),
        showCloseButton: true,
        showBackArrow: false,
        navigateOnClose: NavigationMenu(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              TImages.cancelStatus,
              width: 500,
              height: 200,
              repeat: true,
            ),
            const Text(
              "Giao dịch bị huỷ hoặc thất bại!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
