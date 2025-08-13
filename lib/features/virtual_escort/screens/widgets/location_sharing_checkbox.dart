import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/text_strings.dart';
import '../../controllers/virtual_escort_group_controller.dart';

class LocationSharingCheckbox extends StatelessWidget {
  const LocationSharingCheckbox({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = VirtualEscortGroupController.instance;

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Obx(
            () => Checkbox(
              value: controller.policy.value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) => controller.policy.value = value ?? false,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            TTexts.sharingLocationPolicy,
            style: TextStyle(fontSize: 14,color: Colors.black),
          ),
        ),
      ],
    );
  }
}
