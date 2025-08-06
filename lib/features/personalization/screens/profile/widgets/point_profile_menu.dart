import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class TPointDisplay extends StatelessWidget {
  final int totalPoint;
  final String title;
  final bool isReputationPoint;

  const TPointDisplay({
    super.key,
    required this.totalPoint,
    this.title = 'Tổng điểm',
    this.isReputationPoint = false,
  });

  Color _getPointColor(int point) {
    if (point >= 3) return TColors.success;
    if (point >= 1) return TColors.warning;
    return TColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final displayedPoint = isReputationPoint
        ? (totalPoint > 3 ? 3 : totalPoint)
        : totalPoint;

    final pointColor = isReputationPoint
        ? _getPointColor(displayedPoint)
        : TColors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems / 1.5),
      child: Row(
        children: [
          /// Title
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Value
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$displayedPoint',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: pointColor,
                    ),
                  ),
                  TextSpan(
                    text: ' Điểm',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: pointColor),
                  ),
                ],
              ),
            ),
          ),

          /// Spacer
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
