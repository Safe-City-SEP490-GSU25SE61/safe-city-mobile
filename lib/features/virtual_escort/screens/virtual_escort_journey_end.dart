import 'package:flutter/material.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../navigation_dart.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/helper_functions.dart';

class VirtualEscortJourneyEnd extends StatelessWidget {
  final String duration;
  final String distance;
  final int sosCount;
  final int observerCount;

  const VirtualEscortJourneyEnd({
    super.key,
    this.duration = '00:00',
    this.distance = '0 km',
    this.sosCount = 0,
    this.observerCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: TAppBar(
        title: const Text('Hành trình hoàn tất'),
        showCloseButton: true,
        showBackArrow: false,
        onClose: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavigationMenu()),
            (route) => false,
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            Image.asset(
              TImages.navigationReached,
              height: 280,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),
            const Text(
              "Hành trình bạn đã hoàn tất!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Thời gian di chuyển:", duration, dark),
            _buildDetailRow("Quãng đường đã đi:", distance, dark),
            _buildDetailRow("Số lần gọi SOS:", sosCount.toString(), dark),
            _buildDetailRow(
              "Số người quan sát:",
              observerCount.toString(),
              dark,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NavigationMenu()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Xác nhận",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: dark ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
