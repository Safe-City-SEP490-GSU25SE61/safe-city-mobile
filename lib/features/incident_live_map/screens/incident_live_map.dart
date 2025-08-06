import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:safe_city_mobile/features/incident_live_map/screens/widgets/commune_report_custom_dropdown.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';

import '../../../utils/helpers/helper_functions.dart';
import '../controllers/incident_live_map_controller.dart';
import 'widgets/location_search.dart';

class IncidentLiveMapScreen extends StatefulWidget {
  const IncidentLiveMapScreen({super.key});

  @override
  State<IncidentLiveMapScreen> createState() => _IncidentLiveMapScreenState();
}

class _IncidentLiveMapScreenState extends State<IncidentLiveMapScreen> {
  final goongApiKey = dotenv.env['GOONG_API_KEY']!;
  final mapController = Get.put(IncidentLiveMapController());
  String? selectedFilterStatus;
  String? selectedFilterTime;

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
                "https://tiles.goong.io/assets/goong_map_web.json?$goongApiKey",
            onMapCreated: (controller) {
              final isDarkMode = THelperFunctions.isDarkMode(context);
              mapController.initMap(controller, isDarkMode);
            },
            onTapListener: mapController.onMapClick,
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

          // // Cover Mapbox logo (usually bottom-left)
          // Positioned(
          //   bottom: 80,
          //   right: 8,
          //   child: Container(
          //     width: 100,
          //     height: 30,
          //     color: Theme.of(context).scaffoldBackgroundColor,
          //   ),
          // ),
          Positioned(
            top: 105,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "Khu vực Hồ Chí Minh",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          CustomDropdownStatus(
            onFilterChanged: (status, time) {
              setState(() {
                selectedFilterStatus = status;
                selectedFilterTime = time;
              });
            },
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
            return mapController.isFocusedOnCommune.value
                ? Positioned(
                    bottom: 75,
                    right: 10,
                    child: FloatingActionButton(
                      heroTag: 'back_button',
                      onPressed: () {
                        mapController.exitCommuneFocus();
                        mapController.disableCommuneFocus();
                      },
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDarkMode ? TColors.white : Colors.black,
                        size: 26,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
          Obx(() {
            final isBusy =
                mapController.isLoading.value ||
                mapController.isExitingCommuneFocus.value||
                    mapController.isCommuneReportFocusLoading.value;
            return isBusy
                ? Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: true,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.15),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: TColors.primary,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
