import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../models/goong_prediction_model.dart';

class IncidentLiveMapController extends GetxController {
  MapboxMap? mapboxMap;
  PointAnnotationManager? _customMarkerManager;
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
    final bytes = await rootBundle.load(TImages.currentLocationIconPuck);
    final imageData = bytes.buffer.asUint8List();

    mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        locationPuck: LocationPuck(
          locationPuck2D: DefaultLocationPuck2D(
            topImage: imageData,
            opacity: 10.0,
          ),
        ),
      ),
    );
  }

  Future<void> searchPlace(String input) async {
    final loc = await geo.Geolocator.getCurrentPosition();
    final userLat = loc.latitude;
    final userLng = loc.longitude;

    final acUrl =
        'https://rsapi.goong.io/v2/place/autocomplete'
        '?input=$input'
        '&location=$userLat,$userLng'
        '&limit=5'
        '&has_deprecated_administrative_unit=false'
        '&api_key=$goongMapTilesKey';

    final acRes = await http.get(Uri.parse(acUrl));
    if (acRes.statusCode != 200) return;

    final acData = jsonDecode(acRes.body);
    final preds = (acData['predictions'] as List)
        .map((e) => GoongPredictionModel.fromJson(e))
        .toList();

    final detailedPredictions = await Future.wait(
      preds.map((p) async {
        try {
          final det = await http.get(
            Uri.parse(
              'https://rsapi.goong.io/Place/Detail?place_id=${p.placeId}&api_key=$goongMapTilesKey',
            ),
          );

          if (det.statusCode == 200) {
            final loc = jsonDecode(det.body)['result']['geometry']['location'];
            p.lat = loc['lat'];
            p.lng = loc['lng'];
          } else {
            debugPrint('❌ Place detail failed for ${p.placeId}');
          }
        } catch (e) {
          debugPrint('❌ Exception during place detail: $e');
        }
        return p;
      }),
    );

    final coords = detailedPredictions
        .where((p) => p.lat != null && p.lng != null)
        .toList();

    final destCoords = coords.map((p) => '${p.lat},${p.lng}').join('|');

    if (destCoords.isNotEmpty) {
      final dmUrl =
          'https://rsapi.goong.io/v2/distancematrix'
          '?origins=$userLat,$userLng'
          '&destinations=$destCoords'
          '&vehicle=car'
          '&api_key=$goongMapTilesKey';

      try {
        final dmRes = await http.get(Uri.parse(dmUrl));
        if (dmRes.statusCode == 200) {
          final elements =
              jsonDecode(dmRes.body)['rows'][0]['elements'] as List;

          for (var i = 0; i < coords.length; i++) {
            final el = elements[i];
            coords[i].distanceText = (el['status'] == 'OK')
                ? el['distance']['text']
                : null;
          }
        } else {
          debugPrint('❌ DistanceMatrix failed: ${dmRes.body}');
        }
      } catch (e) {
        debugPrint('❌ Exception during distance matrix fetch: $e');
      }
    }

    predictions.value = coords;
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

      mapboxMap!.setCamera(CameraOptions(center: point, zoom: 12.0));

      mapboxMap!.flyTo(
        CameraOptions(center: point, zoom: 15, bearing: 0, pitch: 0),
        MapAnimationOptions(duration: 2000, startDelay: 0),
      );

      await _addCustomMarker(point);

      predictions.clear();
      searchController.clear();
    } else {
      if (kDebugMode) {
        print("Failed to fetch location detail");
      }
    }
  }

  Future<void> locateUser() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return TLoaders.warningSnackBar(
        title: 'Lỗi',
        message: 'Vui lòng bật định vị GPS',
      );
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        return TLoaders.warningSnackBar(
          title: 'Lỗi',
          message: 'Ứng dụng cần quyền truy cập vị trí',
        );
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      return TLoaders.warningSnackBar(
        title: 'Lỗi',
        message: 'Vị trí đã bị từ chối vĩnh viễn.',
      );
    }

    final position = await geo.Geolocator.getCurrentPosition();
    final lat = position.latitude;
    final lng = position.longitude;

    mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15),
      MapAnimationOptions(duration: 1500),
    );
  }

  Future<void> _addCustomMarker(Point point) async {
    final imageBytes = await getImageFromAsset(TImages.locationIcon);

    _customMarkerManager ??= await mapboxMap!.annotations
        .createPointAnnotationManager();

    await _customMarkerManager!.deleteAll();

    await _customMarkerManager!.create(
      PointAnnotationOptions(
        geometry: point,
        image: imageBytes,
        iconSize: 0.11,
      ),
    );
  }

  Future<Uint8List> getImageFromAsset(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return bytes.buffer.asUint8List();
  }
}
