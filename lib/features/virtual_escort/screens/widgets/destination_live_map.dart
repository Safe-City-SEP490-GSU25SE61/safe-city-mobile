import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:safe_city_mobile/features/virtual_escort/screens/widgets/vehicle_selector.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/virtual_escort_map_controller.dart';
import 'destination_location_search.dart';
import 'destination_search_widget.dart';

class DestinationMapScreen extends StatefulWidget {
  const DestinationMapScreen({super.key});

  @override
  State<DestinationMapScreen> createState() => _DestinationMapScreenState();
}

class _DestinationMapScreenState extends State<DestinationMapScreen> {
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY2']!;
  final mapController = Get.put(VirtualEscortMapController());
  String? originAddress;
  String? destinationAddress;

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
              mapController.initMap(controller, isDarkMode);
            },
          ),

          Positioned(
            top: 40,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: destinationSearchField(
                          label: "Vị trí của bạn",
                          value: originAddress ?? "Vị trí của bạn",
                          onTap: () => _openSearch(true),
                          isDefaultLocation: originAddress == null,
                          prefixIcon: Icon(
                            Iconsax.discover,
                            size: 22,
                            color: originAddress == null
                                ? TColors.accent
                                : Colors.grey,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: "Vị trí hiện tại",
                        icon: Icon(
                          Iconsax.gps,
                          color: originAddress == null
                              ? TColors.accent
                              : Colors.grey,
                        ),
                        onPressed: () async {
                          await mapController.locateUser();
                          setState(() {
                            originAddress = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: destinationSearchField(
                          label: "Chọn điểm đến",
                          value: destinationAddress,
                          onTap: () => _openSearch(false),
                          prefixIcon: const Icon(Iconsax.location, size: 22),
                        ),
                      ),
                      IconButton(
                        tooltip: "Đổi điểm đi / điểm đến",
                        icon: const Icon(Icons.swap_vert, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            final temp = originAddress;
                            originAddress = destinationAddress;
                            destinationAddress = temp;
                          });
                        },
                      ),
                    ],
                  ),
                  destinationAddress?.isNotEmpty == true
                      ? Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(children: [Expanded(child: VehicleSelector())]),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: FloatingActionButton(
              heroTag: 'back_button',
              onPressed: () {
                mapController.clearRouteAndMarker();
                Get.back();
              },
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
          ),

          Positioned(
            bottom: 10,
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
          ),

          Obx(() {
            if (!mapController.showRouteInfoPopup.value) {
              return const SizedBox.shrink();
            }

            return Positioned(
              bottom: 30,
              left: 20,
              right: 80,
              child: AnimatedOpacity(
                opacity: mapController.showRouteInfoPopup.value ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                mapController.selectedVehicle.value == VehicleType.bike
                                    ? Icons.pedal_bike
                                    : Icons.directions_car,
                                color: TColors.accent,
                                size: 30,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vehicleToVietnamese(
                                  mapController.selectedVehicle.value,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.back(
                                result: {
                                  'origin': originAddress ?? '',
                                  'originLat': mapController.originPosition.value?.lat.toDouble(),
                                  'originLng': mapController.originPosition.value?.lng.toDouble(),
                                  'destination': destinationAddress ?? '',
                                  'destinationLat': mapController.destinationPosition.value?.lat.toDouble(),
                                  'destinationLng': mapController.destinationPosition.value?.lng.toDouble(),
                                  'vehicle': vehicleToVietnamese(mapController.selectedVehicle.value),
                                },
                              );
                              mapController.clearRouteAndMarker();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: TColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Áp dụng",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            mapController.routeDurationText.value,
                            style: const TextStyle(
                              fontSize: 16,
                              color: TColors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "(${mapController.routeDistanceText.value})",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _openSearch(bool isOrigin) async {
    final result = await Get.to(() => const LocationSearchScreen());

    if (result != null) {
      final placeId = result['placeId'];
      final description = result['description'];

      setState(() {
        if (isOrigin) {
          originAddress = description;
        } else {
          destinationAddress = description;
        }
      });

      mapController.clearRouteAndMarker();
      await mapController.selectPlace(placeId, isOrigin: isOrigin);

      if (mapController.originPosition.value != null &&
          mapController.destinationPosition.value != null) {
        await mapController.mapDirectionRoute(
          originLat: mapController.originPosition.value!.lat.toDouble(),
          originLng: mapController.originPosition.value!.lng.toDouble(),
          destLat: mapController.destinationPosition.value!.lat.toDouble(),
          destLng: mapController.destinationPosition.value!.lng.toDouble(),
          vehicleType: vehicleToString(mapController.selectedVehicle.value),
        );
      }
    }
  }
}
