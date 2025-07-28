import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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

          // Cover Mapbox logo (usually bottom-left)
          Positioned(
            bottom: 80,
            right: 8,
            child: Container(
              width: 100,
              height: 30,
              color: Theme.of(context).scaffoldBackgroundColor,
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
        ],
      ),
    );
  }
}
