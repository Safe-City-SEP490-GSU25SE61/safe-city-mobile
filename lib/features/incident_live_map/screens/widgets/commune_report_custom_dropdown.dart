import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/incident_live_map_controller.dart';

class CustomDropdownStatus extends StatefulWidget {
  final void Function(String? status, String? time)? onFilterChanged;
  const CustomDropdownStatus({super.key, this.onFilterChanged});

  @override
  State<CustomDropdownStatus> createState() => _CustomDropdownStatusState();
}

class _CustomDropdownStatusState extends State<CustomDropdownStatus> {
  final List<String> statusOptions = [
    'Giao thông',
    'An ninh',
    'Hạ tầng',
    'Môi trường',
    'Khác',
  ];

  final List<String> timeOptions = ['Tuần', 'Tháng', 'Quý'];
  String? selectedStatus;
  String? selectedTime;
  final mapController = Get.put(IncidentLiveMapController());

  void _showFilterDialog() {
    String? tempStatus = selectedStatus;
    String? tempTime = selectedTime;
    final dark = THelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: dark ? TColors.dark : TColors.white,
          title: Text(
            'Bộ lọc',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: dark ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Trạng thái
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Trạng thái',
                  labelStyle: TextStyle(
                    color: dark ? Colors.white : Colors.black,
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                dropdownColor: dark ? Colors.black87 : Colors.white,
                style: TextStyle(color: dark ? Colors.white : Colors.black),
                iconEnabledColor: dark ? Colors.white : Colors.black,
                value: tempStatus,
                items: statusOptions.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  tempStatus = value;
                },
              ),
              const SizedBox(height: 12),

              /// Thời gian
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Thời gian',
                  labelStyle: TextStyle(
                    color: dark ? Colors.white : Colors.black,
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                dropdownColor: dark ? Colors.black87 : Colors.white,
                style: TextStyle(color: dark ? Colors.white : Colors.black),
                iconEnabledColor: dark ? Colors.white : Colors.black,
                value: tempTime,
                items: timeOptions.map((range) {
                  return DropdownMenuItem(
                    value: range,
                    child: Text(
                      range,
                      style: TextStyle(
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  tempTime = value;
                },
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 110,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () async {
                      setState(() {
                        selectedStatus = null;
                        selectedTime = null;
                      });
                      Navigator.of(context).pop();
                      mapController.selectedFilterStatus = null;
                      mapController.selectedFilterTime = null;

                      await mapController.refocusLastCommune();

                      if (widget.onFilterChanged != null) {
                        widget.onFilterChanged!(null, null);
                      }
                    },
                    child: Text(
                      "Thiết lập lại",
                      style: TextStyle(
                        fontSize: 12,
                        color: dark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        selectedStatus = tempStatus;
                        selectedTime = tempTime;
                      });
                      Get.back();
                      mapController.selectedFilterStatus = selectedStatus;
                      mapController.selectedFilterTime = selectedTime;
                      await mapController.refocusLastCommune();
                      if (widget.onFilterChanged != null) {
                        widget.onFilterChanged!(selectedStatus, selectedTime);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text("Áp dụng"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 105,
      right: 14,
      child: GestureDetector(
        onTap: _showFilterDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (selectedStatus != null || selectedTime != null)
                ? TColors.primary
                : Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Iconsax.setting_4,
                size: 18,
                color: (selectedStatus != null || selectedTime != null)
                    ? Colors.white
                    : Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                "Bộ lọc",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: (selectedStatus != null || selectedTime != null)
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
