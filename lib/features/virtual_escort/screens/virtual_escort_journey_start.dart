import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/virtual_escort_journey_end.dart';

import '../../../common/widgets/popup/popup_modal.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';
import '../controllers/virtual_escort_journey_controller.dart';
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
  var hasArrived = false.obs;
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY2']!;
  final mapController = Get.put(VirtualEscortMapController());
  final journeyController = Get.put(VirtualEscortJourneyController());
  List<Position> routePositions = [];
  final popUpModal = PopUpModal.instance;
  Timer? _destinationReachedTimer;
  final secureStorage = const FlutterSecureStorage();

  void showDestinationReachedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Đã đến nơi!"),
          content: const Text("Bạn đã đến điểm đến thành công."),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final biometricEnabled = await secureStorage.read(
                    key: 'is_biometric_login_enabled',
                  );

                  if (biometricEnabled != 'true') {
                    TLoaders.warningSnackBar(
                      title: 'Tính năng chưa được bật',
                      message: 'Vui lòng bật tính năng sinh trắc học để tiếp tục.',
                    );
                    return;
                  }

                  final auth = LocalAuthentication();
                  final didConfirm = await auth.authenticate(
                    localizedReason: 'Xác thực vân tay để xác nhận hành động',
                    options: const AuthenticationOptions(
                      biometricOnly: true,
                      stickyAuth: true,
                    ),
                  );

                  if (didConfirm) {
                    journeyController.stopSendingLocation();
                    Get.to(() => const VirtualEscortJourneyEnd());
                  } else {
                    TLoaders.warningSnackBar(
                      title: 'Xác thực thất bại',
                      message: 'Bạn cần xác thực để tiếp tục.',
                    );
                  }
                } catch (e) {
                  TLoaders.errorSnackBar(
                    title: 'Lỗi',
                    message: 'Đã xảy ra sự cố, vui lòng thử lại sau',
                  );
                }
              },
              child: const Text("Đồng ý"),
            ),
          ],
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    ever(mapController.hasArrived, (arrived) {
      if (arrived) {
        showDestinationReachedDialog();
      }
    });
  }

  @override
  void dispose() {
    _destinationReachedTimer?.cancel();
    super.dispose();
  }

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
                      Obx(() {
                        final text =
                        mapController.currentInstruction.value.isEmpty
                            ? 'Đang tính toán...'
                            : mapController.currentInstruction.value;
                        final limitedText = text.length > 25
                            ? '${text.substring(0, 25)}...'
                            : text;

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
                      }),

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
            top: 128,

            child: Obx(() {
              List<Widget> alerts = [];

              if (journeyController.isInternetWeak.value) {
                alerts.add(
                  popUpModal.buildSidebarAlert(Iconsax.wifi, "Mất mạng"),
                );
              }
              if (journeyController.isBatteryCritical.value) {
                alerts.add(
                  popUpModal.buildSidebarAlert(
                    Iconsax.battery_empty,
                    "Pin rất yếu",
                  ),
                );
              } else if (journeyController.isBatteryLow.value) {
                alerts.add(
                  popUpModal.buildSidebarAlert(
                    Iconsax.battery_empty,
                    "Pin yếu",
                  ),
                );
              }
              if (journeyController.isGpsUnstable.value) {
                alerts.add(
                  popUpModal.buildSidebarAlert(Iconsax.gps, "GPS kém ổn định"),
                );
              }

              if (alerts.isEmpty) return const SizedBox.shrink();

              return SizedBox(
                width: 120,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: alerts,
                  ),
                ),
              );
            }),
          ),
          Positioned(
            bottom: 124,
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
            bottom: 124,
            right: 12,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  popUpModal.showSlideToProceedDialog(
                    title: 'Gửi tín hiệu hỗ trợ',
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
              final durationStr = widget.estimatedTime.isEmpty
                  ? (mapController.routeDurationText.value.isEmpty
                  ? '...'
                  : mapController.routeDurationText.value)
                  : widget.estimatedTime;

              final distance = mapController.routeDistanceText.value.isEmpty
                  ? '...'
                  : mapController.routeDistanceText.value;

              int minutes = 0;
              final regex = RegExp(r'(\d+)');
              final match = regex.firstMatch(durationStr);
              if (match != null) {
                minutes = int.tryParse(match.group(0) ?? '0') ?? 0;
              }
              final arrivalTime = DateTime.now().add(
                Duration(minutes: minutes),
              );
              final formattedArrival = DateFormat.Hm().format(arrivalTime);

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Thời gian",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: TColors.darkerGrey,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    durationStr,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (minutes > 0) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      "• $formattedArrival",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Quãng đường",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: TColors.darkerGrey,
                                    fontWeight: FontWeight.w600),
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
                        ),
                      ],
                    ),
                  ),

                ],
              );
            }),
          ),

        ],
      ),
    );
  }
}
