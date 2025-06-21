import 'package:flutter/material.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';

class IncidentLiveMapScreen extends StatelessWidget {
  const IncidentLiveMapScreen({super.key});

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // 🔥 TODO: Add your API call here to refresh membership data
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: TColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Live Map Screen',
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
