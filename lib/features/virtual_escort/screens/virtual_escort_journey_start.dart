import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../common/widgets/popup/popup_modal.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/virtual_escort_map_controller.dart';

class VirtualEscortJourneyStart extends StatefulWidget {
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final VehicleType vehicle;
  final String estimatedTime;

  const VirtualEscortJourneyStart({
    super.key,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.vehicle,
    required this.estimatedTime,
  });

  @override
  State<VirtualEscortJourneyStart> createState() =>
      VirtualEscortJourneyStartScreen();
}

class VirtualEscortJourneyStartScreen extends State<VirtualEscortJourneyStart> {
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY2']!;
  final mapController = Get.put(VirtualEscortMapController());
  List<Position> routePositions = [];

  @override
  Widget build(BuildContext context) {
    final popUpModal = PopUpModal.instance;
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("map"),
            styleUri:
                "https://tiles.goong.io/assets/goong_map_web.json?$goongMapTilesKey",
            onMapCreated: (controller) async {
              mapController.virtualEscortStartInitMap(controller, isDarkMode);
              await mapController.startVirtualEscort();
            },
          ),
          Positioned(
            top: 50,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF26634F),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1d4f3e),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.straight,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                            () {
                          final text = mapController.currentInstruction.value.isEmpty
                              ? 'Đang tính toán...'
                              : mapController.currentInstruction.value;
                          final limitedText = text.length > 25 ? '${text.substring(0, 25)}...' : text;

                          return Text(
                            limitedText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),

                      Obx(
                        () => Text(
                          mapController.distanceToNext.value.isEmpty
                              ? ''
                              : '${mapController.distanceToNext.value} nữa đến điểm tiếp theo',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 125,
            left: 12,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 5),
                  ),
                  alignment: Alignment.center,
                  child: Obx(
                    () => Column(
                      children: [
                        Text(
                          mapController.speedLimit.value,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          'km/h',
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 125,
            right: 12,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {

                  popUpModal.showSlideToProceedDialog(
                    title: 'SOS Alert',
                    message: 'Bạn có chắc muốn gửi tín hiệu SOS?',
                    onCancel: () {
                      if (kDebugMode) {
                        print('SOS canceled');
                      }
                    },
                  );
                },
                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: TColors.errorContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'SOS',
                    style: TextStyle(
                      color: TColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 26,
            left: 12,
            right: 12,
            child: Obx(() {
              final duration = widget.estimatedTime.isEmpty
                  ? (mapController.routeDurationText.value.isEmpty ? '...' : mapController.routeDurationText.value)
                  : widget.estimatedTime;
              final distance = mapController.routeDistanceText.value.isEmpty
                  ? '...'
                  : mapController.routeDistanceText.value;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Thời gian",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              duration,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Quãng đường",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              distance,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TColors.white,
                        border: Border.all(color: TColors.primary, width: 4),
                      ),
                      child: Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.pause,
                            color: TColors.primary,
                            size: 36,
                          ),
                          onPressed: () {
                            popUpModal.showSlideConfirmPauseDialog(
                              title: "Xác nhận tạm dừng",
                              message: "Bạn có chắc chắn muốn tạm dừng hộ tống?",
                              onConfirm: () {
                                debugPrint("✅ Confirmed");
                              },
                              onCancel: () {
                                debugPrint("❌ Cancelled");
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
