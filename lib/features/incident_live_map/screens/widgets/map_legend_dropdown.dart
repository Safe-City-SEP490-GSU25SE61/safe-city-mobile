import 'package:flutter/material.dart';

class MapLegendDropdown extends StatelessWidget {
  final bool isVisible;

  const MapLegendDropdown({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
      top: isVisible ? 150 : -300,
      right: 170,
      left: 14,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.black),
              ),
              const SizedBox(height: 12),
              _buildLegendItem('assets/images/map/pulsing_dot.gif', 'Vị trí hiện tại'),
              _buildLegendItem('assets/images/map/location-icon.png', 'Vị trí được chọn'),
              _buildLegendItem('assets/images/map/live_map_location_overview.png', 'Tổng quan phường'),
              _buildLegendItem('assets/images/map/traffic.png', 'Sự cố giao thông'),
              _buildLegendItem('assets/images/map/security.png', 'Sự cố an ninh'),
              _buildLegendItem('assets/images/map/environment.png', 'Sự cố môi trường'),
              _buildLegendItem('assets/images/map/infrastructure.png', 'Sự cố hạ tầng'),
              _buildLegendItem('assets/images/map/other.png', 'Sự cố khác'),
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14,color: Colors.black),
          ),
        ),
      ],
    ),
  );
}




