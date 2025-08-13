import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_journey_start.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/destination_live_map.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../controllers/virtual_escort_journey_controller.dart';
import '../controllers/virtual_escort_map_controller.dart';

class VirtualEscortJourneyCreate extends StatelessWidget {
  const VirtualEscortJourneyCreate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VirtualEscortJourneyController());
    final mapController = Get.put(VirtualEscortMapController());
    return Scaffold(
      appBar: TAppBar(title: const Text('Tạo giám sát hành trình'),showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.virtualEscortJourneyFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Destination
                /// Inside your build method:
                Column(
                  children: [
                    /// Điểm xuất phát
                    TextFormField(
                      controller: controller.origin,
                      readOnly: true,
                      onTap: () => _pickLocation(context,controller, controller.origin),
                      validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập điểm xuất phát' : null,
                      decoration: const InputDecoration(
                        labelText: 'Điểm xuất phát',
                        hintText: "Nhập địa chỉ hoặc vị trí bắt đầu",
                        prefixIcon: Icon(Icons.my_location),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// Điểm đến
                    TextFormField(
                      controller: controller.destination,
                      readOnly: true,
                      onTap: () => _pickLocation(context,controller, controller.destination),
                      validator: (value) =>
                      value!.isEmpty ? 'Vui lòng nhập điểm đến' : null,
                      decoration: const InputDecoration(
                        labelText: 'Điểm đến',
                        hintText: "Nhập địa chỉ hoặc vị trí bạn muốn đến",
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Estimated Time & Transport Mode
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: controller.estimatedTime.value,
                        items:
                            ['15 minutes', '30 minutes', '45 minutes', '1 hour']
                                .map(
                                  (time) => DropdownMenuItem(
                                    value: time,
                                    child: Text(time),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => controller.estimatedTime.value =
                            value ?? '15 minutes',
                        decoration: const InputDecoration(
                          labelText: 'Estimated Time',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: controller.transportMode.value,
                        items: ['Walking', 'Driving', 'Cycling']
                            .map(
                              (mode) => DropdownMenuItem(
                                value: mode,
                                child: Text(mode),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            controller.transportMode.value = value ?? 'Walking',
                        decoration: const InputDecoration(
                          labelText: 'Transport Mode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Start Virtual Escort Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final originPos = mapController.originPosition.value;
                      final destPos = mapController.destinationPosition.value;
                      final vehicle = mapController.selectedVehicle.value;

                      if (originPos != null && destPos != null) {
                        Get.to(() => VirtualEscortJourneyStart(
                          originLat: originPos.lat.toDouble(),
                          originLng: originPos.lng.toDouble(),
                          destinationLat: destPos.lat.toDouble(),
                          destinationLng: destPos.lng.toDouble(),
                          vehicle: vehicle,
                        ));
                      } else {
                        Get.snackbar('Error', 'Please select origin and destination first');
                      }
                    },
                    child: const Text('Start Virtual Escort'),
                  ),
                ),

                /// Cancel & Advanced Options Buttons
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => {},
                    // onPressed: () => Get.to(() => VirtualEscortJourneyStart()),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _pickLocation(
    BuildContext context,
    VirtualEscortJourneyController journeyController,
    TextEditingController textController,
    ) async {
  final result = await Get.to(() => const DestinationMapScreen());
  if (result != null && result is Map<String, String>) {
    if (textController == journeyController.origin && result['origin'] != null) {
      textController.text = result['origin']!;
    } else if (textController == journeyController.destination && result['destination'] != null) {
      textController.text = result['destination']!;
    }
  }
}

