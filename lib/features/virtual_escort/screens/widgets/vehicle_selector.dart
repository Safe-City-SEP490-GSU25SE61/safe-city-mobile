import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../controllers/virtual_escort_map_controller.dart';

class VehicleSelector extends StatelessWidget {
  const VehicleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VirtualEscortMapController());
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildVehicleBox(
            VehicleType.car,
            "Ô tô",
            Icons.directions_car,
            controller,
          ),
          _buildVehicleBox(
            VehicleType.bike,
            "Xe máy",
            Icons.motorcycle,
            controller,
          ),
          _buildVehicleBox(
            VehicleType.truck,
            "Xe tải",
            Icons.local_shipping,
            controller,
          ),
          _buildVehicleBox(
            VehicleType.taxi,
            "Taxi",
            Icons.local_taxi,
            controller,
          ),
        ],
      );
    });
  }

  Widget _buildVehicleBox(
      VehicleType type,
      String label,
      IconData icon,
      VirtualEscortMapController controller,
      ) {
    final isSelected = controller.selectedVehicle.value == type;
    return GestureDetector(
      onTap: () => controller.updateVehicle(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

