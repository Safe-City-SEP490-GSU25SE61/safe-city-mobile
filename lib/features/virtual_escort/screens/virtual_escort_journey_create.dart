import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_journey_start.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/destination_live_map.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../controllers/virtual_escort_journey_controller.dart';
import '../controllers/virtual_escort_map_controller.dart';

class VirtualEscortJourneyCreate extends StatelessWidget {
  const VirtualEscortJourneyCreate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VirtualEscortJourneyController());
    final mapController = Get.put(VirtualEscortMapController());
    return Scaffold(
      appBar: TAppBar(
        title: const Text('Tạo giám sát hành trình'),
        showBackArrow: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: controller.virtualEscortJourneyFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Destination
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thông tin di chuyển",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.mediumSpace),

                    /// Điểm xuất phát
                    TextFormField(
                      controller: controller.origin,
                      readOnly: true,
                      onTap: () => _pickStartAndDestinationLocation(
                        context,
                        controller,
                        controller.destination,
                      ),
                      style: TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Vị trí hiện tại',
                        labelStyle: TextStyle(
                          color: TColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: "Vị trí hiện tại",
                        hintStyle: TextStyle(color: TColors.accent),
                        prefixIcon: Icon(Iconsax.gps, color: TColors.accent),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: TSizes.mediumSpace),

                    /// Điểm đến
                    TextFormField(
                      controller: controller.destination,
                      readOnly: true,
                      onTap: () => _pickStartAndDestinationLocation(
                        context,
                        controller,
                        controller.destination,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Vui lòng nhập điểm đến' : null,
                      decoration: const InputDecoration(
                        labelText: 'Điểm đến',
                        hintText: "Nhập địa chỉ hoặc vị trí bạn muốn đến",
                        prefixIcon: Icon(Iconsax.location),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: TSizes.mediumSpace),

                /// Estimated Time & Transport Mode
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        return DropdownButtonFormField<String>(
                          value: mapController.estimatedTime.value.isNotEmpty
                              ? mapController.estimatedTime.value
                              : null,
                          items: mapController.durationOptions
                              .map(
                                (time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(time,style: TextStyle(fontSize: 14),),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              mapController.estimatedTime.value = value ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Thời gian dự tính',
                            border: OutlineInputBorder(),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => TextFormField(
                          key: ValueKey(controller.transportMode.value),
                          initialValue: controller.transportMode.value,
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'Di chuyển bằng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.mediumSpace),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Người giám sát hộ tống",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.mediumSpace),

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
                        Get.to(
                          () => VirtualEscortJourneyStart(
                            originLat: originPos.lat.toDouble(),
                            originLng: originPos.lng.toDouble(),
                            destinationLat: destPos.lat.toDouble(),
                            destinationLng: destPos.lng.toDouble(),
                            vehicle: vehicle,
                          ),
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          'Please select origin and destination first',
                        );
                      }
                    },
                    child: const Text('Bắt đầu hộ tống an toàn'),
                  ),
                ),

                /// Cancel & Advanced Options Buttons
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: TColors.error),
                      foregroundColor: TColors.error,
                    ),
                    onPressed: () {},
                    child: const Text('Hủy'),
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

Future<void> _pickStartAndDestinationLocation(
  BuildContext context,
  VirtualEscortJourneyController journeyController,
  TextEditingController textController,
) async {
  final result = await Get.to(() => const DestinationMapScreen());
  final mapController = Get.find<VirtualEscortMapController>();

  if (result != null && result is Map<String, dynamic>) {
    if (textController == journeyController.destination) {
      textController.text = result['destination'] ?? '';
      final lat = result['destinationLat'] ?? 0.0;
      final lng = result['destinationLng'] ?? 0.0;
      mapController.destinationPosition.value = mb.Position(lng, lat);
    }
    if (textController == journeyController.origin) {
      textController.text = "Your current location";
      if (mapController.originPosition.value == null) {
        final userPos = await Geolocator.getCurrentPosition();
        mapController.originPosition.value = mb.Position(
          userPos.longitude,
          userPos.latitude,
        );
      }
    }

    if (result['vehicle'] != null) {
      journeyController.transportMode.value = result['vehicle'];
    }
  }
}
