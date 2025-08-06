import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class IncidentPieChartShimmer extends StatelessWidget {
  const IncidentPieChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 18.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 22.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
