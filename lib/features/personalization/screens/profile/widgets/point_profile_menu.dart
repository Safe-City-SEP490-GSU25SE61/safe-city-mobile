import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class TPointDisplay extends StatelessWidget {
  final int totalPoint;
  final String title;

  const TPointDisplay({
    super.key,
    required this.totalPoint,
    this.title = 'Tổng điểm',
  });

  @override
  Widget build(BuildContext context) {
    final hasPoints = totalPoint > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems / 1.5),
      child: Row(
        children: [
          /// Title - matches TProfileMenu style
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          /// Value or fallback
          Expanded(
            flex: 4,
            child: hasPoints
                ? Text(
                    '$totalPoint',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  )
                : RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '0',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: TColors.accent,
                          ),
                        ),
                        TextSpan(
                          text: ' Điểm',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: TColors.accent),
                        ),
                      ],
                    ),
                  ),
          ),

          /// Spacer for icon consistency (same structure as TProfileMenu)
          const Expanded(
            child: SizedBox(), // No icon here but keeps alignment clean
          ),
        ],
      ),
    );
  }
}
