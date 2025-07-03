import 'package:flutter/material.dart';
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
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              "Cảm ơn bạn đã thanh toán!",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
