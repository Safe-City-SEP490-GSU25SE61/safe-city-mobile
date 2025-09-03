import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/virtual_escort_journey_controller.dart';
import '../controllers/virtual_escort_map_controller.dart';

class VirtualEscortObserverScreen extends StatefulWidget {
  final int memberId;

  const VirtualEscortObserverScreen({super.key, required this.memberId});

  @override
  State<VirtualEscortObserverScreen> createState() =>
      _VirtualEscortObserverScreenState();
}

class _VirtualEscortObserverScreenState
    extends State<VirtualEscortObserverScreen> {
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY2']!;
  final mapController = Get.put(VirtualEscortMapController());
  final journeyController = Get.put(VirtualEscortJourneyController());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("observer_map"),
            styleUri: "https://tiles.goong.io/assets/goong_map_web.json?$goongMapTilesKey",
            onMapCreated: (controller) async {
              mapController.virtualEscortStartInitMap(controller, isDarkMode);
              await mapController.loadObserverJourney(widget.memberId);
              await journeyController.initConnection(
                isLeader: false,
                memberId: widget.memberId,
              );
            },
          ),
          Positioned(
            bottom: 140,
            right: 12,
            child: FloatingActionButton(
              heroTag: 'locate_button',
              onPressed: () => mapController.locateUser(),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Iconsax.gps,
                color: isDarkMode ? TColors.white : Colors.black,
                size: 26,
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tình trạng người được giám sát",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Obx(() => Column(
                        children: [
                          Icon(
                            journeyController.isBatteryLow.value
                                ? Icons.battery_alert
                                : Icons.battery_full,
                            color: journeyController.isBatteryLow.value
                                ? Colors.red
                                : Colors.green,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journeyController.isBatteryLow.value ? "Pin yếu" : "Pin ổn định",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      )),
                      Obx(() => Column(
                        children: [
                          Icon(
                            journeyController.isGpsUnstable.value
                                ? Icons.gps_not_fixed
                                : Icons.gps_fixed,
                            color: journeyController.isGpsUnstable.value
                                ? Colors.red
                                : Colors.green,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journeyController.isGpsUnstable.value ? "GPS kém" : "GPS ổn định",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      )),
                      Obx(() => Column(
                        children: [
                          Icon(
                            journeyController.isInternetWeak.value
                                ? Icons.wifi_off
                                : Icons.wifi,
                            color: journeyController.isInternetWeak.value
                                ? Colors.red
                                : Colors.green,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            journeyController.isInternetWeak.value ? "Mất mạng" : "Kết nối định",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
