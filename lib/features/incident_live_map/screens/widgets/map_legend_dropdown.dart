import 'package:flutter/material.dart';
import 'package:safe_city_mobile/utils/constants/image_strings.dart';

class MapLegendDropdown extends StatelessWidget {
  final bool isVisible;

  const MapLegendDropdown({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      top: isVisible ? 140 : -300,
      right: 170,
      left: 15,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Chú giải",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,color: Colors.black),
              ),
              _buildLegendItem(TImages.currentLocationIconPuck, 'Vị trí hiện tại'),
              _buildLegendItem(TImages.locationIcon, 'Vị trí được chọn'),
              _buildLegendItem(TImages.communesOverviewIcon, 'Tổng quan phường'),
              _buildLegendItem(TImages.trafficMapIcon, 'Sự cố giao thông'),
              _buildLegendItem(TImages.securityMapIcon, 'Sự cố an ninh'),
              _buildLegendItem(TImages.environmentMapIcon, 'Sự cố môi trường'),
              _buildLegendItem(TImages.infrastructureMapIcon, 'Sự cố hạ tầng'),
              _buildLegendItem(TImages.otherMapIcon, 'Sự cố khác'),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildLegendItem(String imagePath, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Image.asset(
          imagePath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}




