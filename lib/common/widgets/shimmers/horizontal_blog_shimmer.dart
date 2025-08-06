import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';
import '../effects/shimmer_effect.dart';

class THorizontalProductShimmer extends StatelessWidget {
  const THorizontalProductShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            itemCount,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    // Image shimmer
                    TShimmerEffect(width: 180, height: 180),
                    SizedBox(height: TSizes.spaceBtwItems),
                    // Title shimmer
                    TShimmerEffect(width: 160, height: 15),
                    SizedBox(height: TSizes.spaceBtwItems / 2),
                    // Subtitle shimmer
                    TShimmerEffect(width: 110, height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
