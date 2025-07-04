import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:safe_city_mobile/utils/constants/image_strings.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../navigation_dart.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: const Text('Thanh toán thành công'),
        showCloseButton: true,
        showBackArrow: false,
        navigateOnClose: NavigationMenu(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              TImages.successStatus,
              width: 400,
              height: 200,
              repeat: true,
            ),
            const SizedBox(height: 20),
            const Text(
              "Cảm ơn bạn đã thanh toán!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
