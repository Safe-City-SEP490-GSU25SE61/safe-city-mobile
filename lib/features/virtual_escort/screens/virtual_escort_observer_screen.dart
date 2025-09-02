import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

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
      body: MapWidget(
        key: const ValueKey("observer_map"),
        styleUri:
            "https://tiles.goong.io/assets/goong_map_web.json?$goongMapTilesKey",
        onMapCreated: (controller) async {
          mapController.virtualEscortStartInitMap(controller, isDarkMode);
          await mapController.loadObserverJourney(widget.memberId);
          await journeyController.initConnection(isLeader: false,memberId: widget.memberId);
        },
      ),
    );
  }
}
