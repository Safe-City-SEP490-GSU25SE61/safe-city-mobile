import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_journey_start.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/destination_live_map.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/group_members_selector.dart';

import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../controllers/virtual_escort_group_controller.dart';
import '../controllers/virtual_escort_journey_controller.dart';
import '../controllers/virtual_escort_map_controller.dart';

class VirtualEscortJourneyCreate extends StatelessWidget {
  final int groupId;
  final int memberId;

  VirtualEscortJourneyCreate({super.key, required this.groupId, required this.memberId});

  final RxList<int> selectedWatcherIds = <int>[].obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VirtualEscortJourneyController());
    final groupController = Get.put(VirtualEscortGroupController());
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
                                  child: Text(
                                    time,
                                    style: TextStyle(fontSize: 14),
                                  ),
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
                Card(
                  color: TColors.lightGrey,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide.none,
                  ),
                  child: SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: GroupMembersWidget(
                        group: groupController.groupDetail.value,
                        onSelectionChanged: (ids) {
                          selectedWatcherIds.assignAll(ids);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: TSizes.mediumSpace),

                /// Lưu ý
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TColors.warningContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.lamp_on, color: TColors.warning),
                      const SizedBox(width: TSizes.xs),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: TColors.warning,
                              fontSize: 13,
                            ),
                            children: [
                              const TextSpan(
                                text: '${TTexts.importantNotice}\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextSpan(text: TTexts.importantSafetyInformation),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.mediumSpace),

                /// Start Virtual Escort Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      final secureStorage = const FlutterSecureStorage();
                      final originPos = mapController.originPosition.value;
                      final destPos = mapController.destinationPosition.value;
                      final vehicleForRoute = mapController.selectedVehicle.value;
                      final vehicle = mapController.selectedVehicle.value.toString().split('.').last;
                      final group = groupController.groupDetail.value;
                      final hasMembers = group != null && group.members.any((m) => m.role != "Leader");
                      final biometricEnabled = await secureStorage.read(
                        key: 'is_biometric_login_enabled',
                      );

                      if (biometricEnabled != 'true') {
                        TLoaders.warningSnackBar(
                          title: 'Tính năng chưa được bật',
                          message: 'Vui lòng kích hoạt xác thực vân tay để bắt đầu hành trình',
                        );
                        return;
                      }

                      if (!hasMembers) {
                        TLoaders.warningSnackBar(
                          title: 'Không có thành viên',
                          message: 'Nhóm không có thành viên nào để giám sát',
                        );
                        return;
                      }

                      if (selectedWatcherIds.isEmpty) {
                        TLoaders.warningSnackBar(
                          title: 'Không có thành viên giám sát',
                          message: 'Vui lòng chọn ít nhất một người giám sát',
                        );
                        return;
                      }

                      if (originPos != null && destPos != null) {
                        final distance = mapController.routeDistanceText.value.isEmpty
                            ? '...'
                            : mapController.routeDistanceText.value;
                        Get.to(
                          () => VirtualEscortJourneyStart(
                            originLat: originPos.lat.toDouble(),
                            originLng: originPos.lng.toDouble(),
                            destinationLat: destPos.lat.toDouble(),
                            destinationLng: destPos.lng.toDouble(),
                            vehicle: vehicleForRoute,
                            estimatedTime: mapController.estimatedTime.value,
                            routeDistance: distance,
                            observerCount: selectedWatcherIds.length,
                          ),
                        );
                        await mapController.createEscortAfterRoute(
                          groupId: groupId,
                          vehicle: vehicle,
                          watcherIds: selectedWatcherIds.toList(), rawJson: mapController.rawRouteData.value,
                        );
                        await controller.initConnection(isLeader: true,memberId: memberId);
                        await controller.startSendingLocation();
                      } else {
                        TLoaders.warningSnackBar(
                          title: 'Không có điểm đến',
                          message: 'Vui lòng chọn ít điểm đến cho hành trình',
                        );
                        return;
                      }
                    },
                    child: const Text('Bắt đầu hộ tống an toàn'),
                  ),
                ),

                /// Cancel & Advanced Options Buttons
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
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
