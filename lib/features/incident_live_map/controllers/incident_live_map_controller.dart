import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/goong_prediction_model.dart';

class IncidentLiveMapController extends GetxController {
  MapboxMap? mapboxMap;

  final goongApiKey = dotenv.env['GOONG_API_KEY']!;
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY']!;
  final searchController = TextEditingController();
  final RxList<GoongPredictionModel> predictions = <GoongPredictionModel>[].obs;

  Future<void> initMap(MapboxMap controller, bool isDarkMode) async {
    mapboxMap = controller;
    mapboxMap!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(106.67393252105423, 10.831951418898154),
        ),
        zoom: 14.0,
      ),
    );

    final darkStyle =
        "https://tiles.goong.io/assets/goong_map_dark.json?$goongApiKey";
    final lightStyle =
        "https://tiles.goong.io/assets/goong_map_web.json?$goongApiKey";

    mapboxMap!.loadStyleURI(isDarkMode ? darkStyle : lightStyle);
  }

  Future<void> searchPlace(String input) async {
    final url =
        'https://rsapi.goong.io/Place/AutoComplete?api_key=$goongMapTilesKey&input=$input';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List items = data['predictions'];
      predictions.value = items
          .map((e) => GoongPredictionModel.fromJson(e))
          .toList();
    }
  }

  Future<void> selectPlace(String placeId) async {
    final url =
        'https://rsapi.goong.io/Place/Detail?place_id=$placeId&api_key=$goongMapTilesKey';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final loc = data['result']['geometry']['location'];
      final lat = loc['lat'];
      final lng = loc['lng'];
      if (kDebugMode) {
        print("✅ Coordinates from Goong API: lat=$lat, lng=$lng");
      }

      if (mapboxMap == null) {
        if (kDebugMode) {
          print("❌ mapboxMap is null. Did you assign it correctly in initMap?");
        }
        return;
      }

      final point = Point(coordinates: Position(lng, lat));

      // Optional: move camera instantly first
      mapboxMap!.setCamera(
        CameraOptions(
          center: point,
          zoom: 12.0,
        ),
      );

      // Then animate to zoom in smoothly
      mapboxMap!.flyTo(
        CameraOptions(
          center: point, // ✅ This was missing
          zoom: 15,
          bearing: 0,
          pitch: 0,
        ),
        MapAnimationOptions(duration: 2000, startDelay: 0),
      );

      predictions.clear();
      searchController.clear();
    } else {
      if (kDebugMode) {
        print("Failed to fetch location detail");
      }
    }
  }

}
