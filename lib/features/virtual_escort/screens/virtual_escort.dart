import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../utils/constants/sizes.dart';

class VirtualEscortScreen extends StatelessWidget {
  const VirtualEscortScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // 🔥 TODO: Add your API call here to refresh membership data
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Giám sát an toàn',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          InkWell(
            onTap: () {
              // Handle Lịch sử
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
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
          const SizedBox(width: TSizes.mediumSpace),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Virtual Escort Screen',
              style: TextStyle(
                fontSize: 18,
                color: dark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
