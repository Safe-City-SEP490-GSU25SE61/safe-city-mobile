import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/incident_report_controller.dart';
import '../../controllers/map_controller.dart';
import 'location_search.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY1']!;
  final mapController = Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("map"),
            styleUri:
                "https://tiles.goong.io/assets/goong_map_web.json?$goongMapTilesKey",
            onMapCreated: (controller) {
              final isDarkMode = THelperFunctions.isDarkMode(context);
              mapController.initMap(controller, isDarkMode);
            },
          ),

          Positioned(
            top: 40,
            left: 14,
            right: 14,
            child: GestureDetector(
              onTap: () async {
                final placeId = await Get.to(
                  () => const LocationSearchScreen(),
                );
                if (placeId != null) {
                  mapController.selectPlace(placeId);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Tìm địa điểm...',
                    hintStyle: const TextStyle(color: Colors.black),
                    prefixIcon: const Icon(Iconsax.search_normal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Obx(() {
            final location = mapController.selectedLocation.value;
            if (location == null) return const SizedBox.shrink();

            return Positioned(
              bottom: 30,
              left: 10,
              right: 10,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(TSizes.mediumSpace),
                    // extra bottom padding for button
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.location, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.mainText,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: TSizes.md,
                                    ),
                                  ),
                                  Text(
                                    location.secondaryText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (location.formattedDistance != null)
                                    Text(
                                      "Khoảng cách: ${location.formattedDistance}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.smallSpace),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final reportController = Get.find<IncidentReportController>();
                              reportController.address.text = location.description;
                              reportController.lat.value = location.lat!;
                              reportController.lng.value = location.lng!;
                              Get.back();
                            },
                            child: const Text("Chọn địa điểm"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => mapController.clearSelectedLocation(),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          Obx(() {
            final location = mapController.selectedLocation.value;
            if (location != null) return const SizedBox.shrink();

            return Positioned(
              bottom: 80,
              right: 10,
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
            );
          }),

          Obx(() {
            final location = mapController.selectedLocation.value;
            if (location != null) return const SizedBox.shrink();

            return Positioned(
              bottom: 10,
              right: 10,
              child: FloatingActionButton(
                heroTag: 'back_button',
                onPressed: () => Get.back(),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? TColors.white : Colors.black,
                  size: 26,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
