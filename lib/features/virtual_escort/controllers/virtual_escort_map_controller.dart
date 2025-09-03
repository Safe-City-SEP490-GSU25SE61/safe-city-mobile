import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:safe_city_mobile/utils/constants/colors.dart';
import '../../../data/services/virtual_escort/virtual_escort_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/popups/loaders.dart';
import '../models/goong_prediction_model.dart';
import '../models/route_step_model.dart';
import '../screens/virtual_escort_journey_start.dart';

class VirtualEscortMapController extends GetxController {
  static VirtualEscortMapController get instance => Get.find();
  final escortService = VirtualEscortService();
  MapboxMap? mapboxMap;
  PointAnnotationManager? _customMarkerManager;
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY2']!;
  final goongApiKey = dotenv.env['GOONG_API_KEY2']!;
  final searchController = TextEditingController();
  final RxList<GoongPredictionModel> predictions = <GoongPredictionModel>[].obs;
  final originPosition = Rxn<Position>();
  final destinationPosition = Rxn<Position>();
  final selectedVehicle = VehicleType.bike.obs;
  final RxString routeDistanceText = ''.obs;
  final RxString routeDurationText = ''.obs;
  final RxString routeVehicleType = ''.obs;
  final RxBool showRouteInfoPopup = false.obs;
  final secureStorage = const FlutterSecureStorage();
  final RxList<String> durationOptions = <String>[].obs;
  final RxString estimatedTime = ''.obs;
  PointAnnotationManager? _markerManager;
  var currentInstruction = ''.obs;
  var distanceToNext = ''.obs;
  final speedLimit = '--'.obs;
  double? smoothedBearing;
  Position? lastGpsPosition;
  Position? nextGpsPosition;
  Position? currentInterpolated;
  DateTime? lastGpsTime;
  Timer? trackingTimer;
  StreamSubscription<geo.Position>? positionStream;
  double? expectedTravelTime;
  final List<Position> gpsHistory = [];
  bool isUserOffRoute = false;
  final double _earthRadius = 6371000.0;
  double latestSpeed = 0.0;
  DateTime? _lastStepUpdateTime;
  Position? _lastMarkerPosition;
   double gpsUpdateThreshold = 3.0;
   double markerMoveThreshold = 1.5;
  var hasArrived = false.obs;
  final rawRouteData = {}.obs;
  PointAnnotation? _observerMarker;

  @override
  void onClose() {
    try {
      if (_markerManager != null && mapboxMap != null) {
        _markerManager?.deleteAll();
      }
    } catch (e) {
      debugPrint("MarkerManager cleanup skipped: $e");
    }
    _markerManager = null;
    mapboxMap = null;
    super.onClose();
  }

  Future<void> initMap(MapboxMap controller, bool isDarkMode) async {
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
        message:
        'Vị trí đã bị từ chối vĩnh viễn. Vui lòng bật quyền trong cài đặt.',
      );
    }

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
        "https://tiles.goong.io/assets/goong_map_dark.json?$goongMapTilesKey";
    final lightStyle =
        "https://tiles.goong.io/assets/goong_map_web.json?$goongMapTilesKey";
    final styleUri = isDarkMode ? darkStyle : lightStyle;
    await mapboxMap!.loadStyleURI(styleUri);
    final bytes = await rootBundle.load(TImages.currentLocationIconPuck);
    final imageData = bytes.buffer.asUint8List();

    mapboxMap!.location.updateSettings(
      LocationComponentSettings(
        pulsingEnabled: true,
        enabled: true,
        locationPuck: LocationPuck(
          locationPuck2D: DefaultLocationPuck2D(
            topImage: imageData,
            opacity: 10.0,
          ),
        ),
      ),
    );
    if (originPosition.value != null && destinationPosition.value != null) {
      await mapDirectionRoute(
        originLat: originPosition.value!.lat.toDouble(),
        originLng: originPosition.value!.lng.toDouble(),
        destLat: destinationPosition.value!.lat.toDouble(),
        destLng: destinationPosition.value!.lng.toDouble(),
      );
    }
  }

  Future<void> searchPlace(String input) async {
    final loc =
        await geo.Geolocator.getLastKnownPosition() ??
            await geo.Geolocator.getCurrentPosition();

    final userLat = loc.latitude;
    final userLng = loc.longitude;

    final acUrl =
        'https://rsapi.goong.io/v2/place/autocomplete?input=$input&location=$userLat,$userLng&limit=5&has_deprecated_administrative_unit=false&api_key=$goongApiKey';

    final acRes = await http.get(Uri.parse(acUrl));
    if (acRes.statusCode != 200) return;

    final preds = (jsonDecode(acRes.body)['predictions'] as List)
        .map((e) => GoongPredictionModel.fromJson(e))
        .toList();

    final detailed = await Future.wait(
      preds.map((p) async {
        try {
          final res = await http
              .get(
            Uri.parse(
              'https://rsapi.goong.io/Place/Detail?place_id=${p.placeId}&api_key=$goongApiKey',
            ),
          )
              .timeout(const Duration(seconds: 3));
          if (res.statusCode == 200) {
            final loc = jsonDecode(res.body)['result']['geometry']['location'];
            p.lat = loc['lat'];
            p.lng = loc['lng'];
          }
        } catch (_) {}
        return p;
      }),
    );

    final coords = detailed
        .where((p) => p.lat != null && p.lng != null)
        .toList();

    if (coords.isEmpty) return;

    final destCoords = coords.map((p) => '${p.lat},${p.lng}').join('|');

    final dmUrl =
        'https://rsapi.goong.io/v2/distancematrix?origins=$userLat,$userLng&destinations=$destCoords&vehicle=car&api_key=$goongApiKey';

    try {
      final dmRes = await http.get(Uri.parse(dmUrl));
      if (dmRes.statusCode == 200) {
        final elements = jsonDecode(dmRes.body)['rows'][0]['elements'] as List;
        for (var i = 0; i < coords.length; i++) {
          final el = elements[i];
          coords[i].distanceText = el['status'] == 'OK'
              ? el['distance']['text']
              : null;
        }
      }
    } catch (e) {
      debugPrint('❌ Distance matrix error: $e');
    }

    predictions.value = coords;
  }

  Future<void> selectPlace(String placeId, {bool isOrigin = false}) async {
    final url =
        'https://rsapi.goong.io/v2/place/detail?place_id=$placeId&api_key=$goongApiKey';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final loc = data['result']['geometry']['location'];
      final lat = loc['lat'];
      final lng = loc['lng'];

      final pos = Position(lng, lat);
      if (isOrigin) {
        originPosition.value = pos;
      } else {
        destinationPosition.value = pos;
      }

      if (mapboxMap == null) {
        if (kDebugMode) {
          print("❌ mapboxMap is null");
        }
        return;
      }

      final point = Point(coordinates: Position(lng, lat));

      mapboxMap!.flyTo(
        CameraOptions(center: point, zoom: 15, bearing: 0, pitch: 0),
        MapAnimationOptions(duration: 2000),
      );

      await _addCustomMarker(point);

      predictions.clear();
      searchController.clear();

      if (originPosition.value == null) {
        await locateUser(saveAsOrigin: true);
      }
      if (originPosition.value != null && destinationPosition.value != null) {
        await mapDirectionRoute(
          originLat: originPosition.value!.lat.toDouble(),
          originLng: originPosition.value!.lng.toDouble(),
          destLat: destinationPosition.value!.lat.toDouble(),
          destLng: destinationPosition.value!.lng.toDouble(),
        );
      }
    } else {
      if (kDebugMode) {
        debugPrint(
          "❌ Failed to fetch location detail "
              "(HTTP ${res.statusCode}): ${res.body}",
        );
      }
    }
  }

  Future<void> locateUser({bool saveAsOrigin = false}) async {
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

    final pos = Position(lng, lat);
    if (saveAsOrigin) originPosition.value = pos;

    mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15),
      MapAnimationOptions(duration: 1500),
    );
  }

  Future<void> _recreateMarkerManager() async {
    if (mapboxMap == null) return;
    try {
      try {
        _customMarkerManager?.deleteAll();
      } catch (_) {}
      _markerManager = await mapboxMap!.annotations
          .createPointAnnotationManager();
    } catch (e) {
      debugPrint('❌ Failed to create PointAnnotationManager: $e');
      _markerManager = null;
    }
  }

  Future<void> _ensureMarkerManager() async {
    if (mapboxMap == null) return;
    if (_markerManager == null) {
      await _recreateMarkerManager();
      return;
    }
    try {
      await _markerManager!.deleteAll();
    } catch (_) {
      await _recreateMarkerManager();
    }
  }

  Future<void> clearRouteAndMarker() async {
    try {
      await _markerManager?.deleteAll();
    } catch (_) {}
    try {
      _customMarkerManager?.deleteAll();
    } catch (_) {}
    _markerManager = null;
    await _removeRouteLayersAndSource();
    showRouteInfoPopup.value = false;
  }

  Future<void> _addCustomMarker(Point point) async {
    if (mapboxMap == null) {
      debugPrint('⚠️ mapboxMap is null, cannot add marker');
      return;
    }
    final imageBytes = await getImageFromAsset(TImages.locationIcon);
    await _ensureMarkerManager();
    if (_markerManager == null) return;

    try {
      await _markerManager!.deleteAll();
      await _markerManager!.create(
        PointAnnotationOptions(
          geometry: point,
          image: imageBytes,
          iconSize: 0.11,
        ),
      );
    } catch (e) {
      debugPrint('❌ Failed to add marker: $e');
    }
  }

  Future<Uint8List> getImageFromAsset(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return bytes.buffer.asUint8List();
  }

  Future<MbxImage> loadMbxImageFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteDataRGBA = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    return MbxImage(
      width: image.width,
      height: image.height,
      data: byteDataRGBA!.buffer.asUint8List(),
    );
  }

  Future<void> _removeRouteLayersAndSource() async {
    if (mapboxMap == null) return;

    try {
      final style = mapboxMap!.style;

      final existingLayers = await style.getStyleLayers();
      final layerIdsToRemove = [
        'route_layer',
        'route_outline_layer',
        'route_markers_layer',
        'route_arrows_layer',
      ];

      for (final id in layerIdsToRemove) {
        if (existingLayers.any((l) => l?.id == id)) {
          try {
            await style.removeStyleLayer(id);
            debugPrint('✅ Removed layer $id');
          } catch (e) {
            debugPrint('⚠️ Failed to remove layer $id: $e');
          }
        }
      }

      final existingSources = await style.getStyleSources();
      final sourceIdsToRemove = [
        'route_source',
        'route_markers',
        'route_arrows',
      ];

      for (final id in sourceIdsToRemove) {
        if (existingSources.any((s) => s?.id == id)) {
          try {
            await style.removeStyleSource(id);
            debugPrint('✅ Removed source $id');
          } catch (e) {
            debugPrint('⚠️ Failed to remove source $id: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error removing route layers/sources: $e');
    }
  }

  Future<List<Position>> mapDirectionRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String vehicleType = 'bike',
  }) async {
    try {
      if (mapboxMap == null) return [];

      final url = Uri.parse(
        'https://rsapi.goong.io/v2/direction'
            '?origin=$originLat,$originLng'
            '&destination=$destLat,$destLng'
            '&vehicle=$vehicleType'
            '&alternatives=false'
            '&api_key=$goongApiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint('❌ Failed to load route: ${response.body}');
        return [];
      }

      final data = jsonDecode(response.body);
      rawRouteData.value = data;
      loadRouteAndStartTracking(response.body);
      final polyline =
      data['routes'][0]['overview_polyline']['points'] as String;
      final List<Position> positions = _decodePolylineToPositions(polyline);
      final densePositions = densifyRoute(positions, step: 12);

      final existingPolyline = await secureStorage.read(key: 'escort_polyline');
      final existingEscortResponse = await secureStorage.read(key: 'escort_response');
      if (existingPolyline != null || existingEscortResponse!=null) {
        await secureStorage.delete(key: 'escort_polyline');
        await secureStorage.delete(key: 'escort_dense_positions');
        await secureStorage.delete(key: 'escort_response');
      }
      await secureStorage.write(key: 'escort_polyline', value: polyline);

      final denseJson = jsonEncode(
        densePositions.map((p) => {'lat': p.lat, 'lng': p.lng}).toList(),
      );
      await secureStorage.write(
        key: 'escort_dense_positions',
        value: denseJson,
      );

      final featureCollection = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "id": "route_1",
            "properties": {},
            "geometry": {
              "type": "LineString",
              "coordinates": positions.map((p) => [p.lng, p.lat]).toList(),
            },
          },
        ],
      };

      final routeInfo = data['routes'][0]['legs'][0];
      routeDurationText.value = routeInfo['duration']['text'] ?? '';

      routeDistanceText.value = routeInfo['distance']['text'] ?? '';
      routeDurationText.value = routeInfo['duration']['text'] ?? '';
      routeVehicleType.value = vehicleType;

      String durationText = routeInfo['duration']['text'] ?? '0 phút';
      int baseMinutes = 0;

      final regexHours = RegExp(r'(\d+)\s*giờ');
      final regexMinutes = RegExp(r'(\d+)\s*phút');

      final hourMatch = regexHours.firstMatch(durationText);
      final minuteMatch = regexMinutes.firstMatch(durationText);

      if (hourMatch != null) {
        baseMinutes += int.parse(hourMatch.group(1)!) * 60;
      }
      if (minuteMatch != null) {
        baseMinutes += int.parse(minuteMatch.group(1)!);
      }

      List<String> newOptions = [
        THelperFunctions.formatDurationInMinutes(baseMinutes),
        THelperFunctions.formatDurationInMinutes(baseMinutes + 5),
        THelperFunctions.formatDurationInMinutes(baseMinutes + 10),
      ];

      durationOptions.assignAll(newOptions);
      estimatedTime.value = newOptions.first;

      final steps = routeInfo['steps'] as List;
      final List<Map<String, dynamic>> navigationSteps = steps.map((step) {
        return {
          "instruction": step['html_instructions'] ?? '',
          "maneuver": step['maneuver'] ?? '',
          "polyline": step['polyline']?['points'] ?? '',
          "start_location": step['start_location'],
        };
      }).toList();

      await secureStorage.write(
        key: 'escort_steps',
        value: jsonEncode(navigationSteps),
      );

      routeDistanceText.value = routeInfo['distance']['text'] ?? '';
      routeDurationText.value = routeInfo['duration']['text'] ?? '';
      routeVehicleType.value = vehicleType;

      showRouteInfoPopup.value = true;

      await mapboxMap!.style.addSource(
        GeoJsonSource(id: 'route_source', data: jsonEncode(featureCollection)),
      );

      await mapboxMap!.style.addLayerAt(
        LineLayer(
          id: 'route_outline_layer',
          sourceId: 'route_source',
          lineColor: TColors.primary.toARGB32(),
          lineWidth: 12.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
        LayerPosition(below: 'highway-name-minor'),
      );

      await mapboxMap!.style.addLayerAt(
        LineLayer(
          id: 'route_layer',
          sourceId: 'route_source',
          lineColor: TColors.accent.toARGB32(),
          lineWidth: 8.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
        LayerPosition(below: 'highway-name-minor'),
      );

      await loadRouteIcons();

      await mapboxMap!.style.addSource(
        GeoJsonSource(
          id: 'route_markers',
          data: jsonEncode({
            "type": "FeatureCollection",
            "features": [
              {
                "type": "Feature",
                "geometry": {
                  "type": "Point",
                  "coordinates": [positions.first.lng, positions.first.lat],
                },
                "properties": {"icon": "route_start_icon"},
              },
              {
                "type": "Feature",
                "geometry": {
                  "type": "Point",
                  "coordinates": [positions.last.lng, positions.last.lat],
                },
                "properties": {"icon": "route_end_icon"},
              },
            ],
          }),
        ),
      );

      await mapboxMap!.style.addLayerAt(
        SymbolLayer(
          id: 'route_markers_layer',
          sourceId: 'route_markers',
          iconImageExpression: ["get", "icon"],
          iconSize: 0.02,
          iconAllowOverlap: false,
          iconIgnorePlacement: false,
        ),
        LayerPosition(below: 'highway-name-minor'),
      );

      await mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(positions.first.lng, positions.first.lat),
          ),
          zoom: 15,
        ),
        MapAnimationOptions(duration: 1500),
      );
      return densePositions;
    } catch (e) {
      debugPrint('❌ Failed to load route: $e');
      return [];
    }
  }

  List<Position> densifyRoute(List<Position> route, {double step = 15}) {
    final dense = <Position>[];
    for (var i = 0; i < route.length - 1; i++) {
      final start = route[i];
      final end = route[i + 1];
      final dist = calculateDistance(
        start.lat as double,
        start.lng as double,
        end.lat as double,
        end.lng as double,
      );
      final segments = (dist / step).ceil().clamp(1, 1000);

      for (var j = 0; j < segments; j++) {
        final t = j / segments;
        dense.add(
          Position.named(
            lat: start.lat * (1 - t) + end.lat * t,
            lng: start.lng * (1 - t) + end.lng * t,
          ),
        );
      }
    }
    dense.add(route.last);
    return dense;
  }

  List<Position> _decodePolylineToPositions(String encoded) {
    List<Position> positions = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      positions.add(Position((lng / 1E5).toDouble(), (lat / 1E5).toDouble()));
    }
    return positions;
  }

  ({Point center}) _getRouteBounds(List<Position> positions) {
    double minLat = positions.first.lat.toDouble();
    double maxLat = positions.first.lat.toDouble();
    double minLng = positions.first.lng.toDouble();
    double maxLng = positions.first.lng.toDouble();

    for (var pos in positions) {
      if (pos.lat < minLat) minLat = pos.lat.toDouble();
      if (pos.lat > maxLat) maxLat = pos.lat.toDouble();
      if (pos.lng < minLng) minLng = pos.lng.toDouble();
      if (pos.lng > maxLng) maxLng = pos.lng.toDouble();
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    return (center: Point(coordinates: Position(centerLng, centerLat)));
  }

  ({Point center}) getRouteBounds(List<Position> positions) {
    return _getRouteBounds(positions);
  }

  Future<MbxImage> getImage(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return await _decodeImage(bytes.buffer.asUint8List());
  }

  Future<MbxImage> _decodeImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception("Failed to convert image to byte data");
    }

    return MbxImage(
      data: byteData.buffer.asUint8List(),
      width: image.width,
      height: image.height,
    );
  }

  Future<void> loadRouteIcons() async {
    try {
      final startMbxImage = await getImage(TImages.directionLocationIcon);
      await mapboxMap!.style.addStyleImage(
        'route_start_icon',
        1.0,
        startMbxImage,
        false,
        [],
        [],
        null,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to load start icon: $e');
    }

    try {
      final endMbxImage = await getImage(TImages.directionLocationIcon);
      await mapboxMap!.style.addStyleImage(
        'route_end_icon',
        1.0,
        endMbxImage,
        false,
        [],
        [],
        null,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to load end icon: $e');
    }
  }

  Future<void> updateVehicle(VehicleType vehicle) async {
    selectedVehicle.value = vehicle;
    if (originPosition.value != null && destinationPosition.value != null) {
      await mapDirectionRoute(
        originLat: originPosition.value!.lat.toDouble(),
        originLng: originPosition.value!.lng.toDouble(),
        destLat: destinationPosition.value!.lat.toDouble(),
        destLng: destinationPosition.value!.lng.toDouble(),
        vehicleType: vehicleToString(vehicle),
      );
    }
  }

  Future<void> virtualEscortStartInitMap(
      MapboxMap controller,
      bool isDarkMode,
      ) async {
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
        "https://tiles.goong.io/assets/goong_map_dark.json?$goongMapTilesKey";
    final lightStyle =
        "https://tiles.goong.io/assets/goong_map_web.json?$goongMapTilesKey";
    final styleUri = isDarkMode ? darkStyle : lightStyle;
    await mapboxMap!.loadStyleURI(styleUri);
  }

  Future<void> startVirtualEscort() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return TLoaders.warningSnackBar(
          title: 'Lỗi',
          message: 'Vui lòng bật định vị GPS để bắt đầu hành trình.',
        );
      }

      geo.LocationPermission permission =
      await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.denied) {
          return TLoaders.warningSnackBar(
            title: 'Lỗi',
            message: 'Ứng dụng cần quyền truy cập vị trí.',
          );
        }
      }
      if (permission == geo.LocationPermission.deniedForever) {
        return TLoaders.warningSnackBar(
          title: 'Lỗi',
          message:
          'Vị trí đã bị từ chối vĩnh viễn. Vui lòng vào cài đặt để điều chỉnh.',
        );
      }

      await _removeRouteLayersAndSource();

      final storage = const FlutterSecureStorage();
      final polyline = await storage.read(key: 'escort_polyline');
      if (polyline == null) {
        debugPrint('⚠️ No saved polyline found');
        return;
      }
      final denseJson = await storage.read(key: 'escort_dense_positions');
      late final List<Position> positions;

      if (denseJson != null) {
        final decoded = jsonDecode(denseJson) as List;
        positions = decoded
            .map((e) => Position.named(lat: e['lat'], lng: e['lng']))
            .toList();
      } else {
        positions = _decodePolylineToPositions(polyline);
      }
      startUserTrackingAlongRoute(positions);
      final arrowFeatures = <Map<String, dynamic>>[];

      for (var i = 0; i < positions.length - 1; i++) {
        final bearing = calculateBearing(positions[i], positions[i + 1]);
        arrowFeatures.add({
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [positions[i].lng, positions[i].lat],
          },
          "properties": {"icon": "step_arrow_icon", "bearing": bearing},
        });
      }

      final arrowFeatureCollection = {
        "type": "FeatureCollection",
        "features": arrowFeatures,
      };

      final featureCollection = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "id": "route_1",
            "properties": {},
            "geometry": {
              "type": "LineString",
              "coordinates": positions.map((p) => [p.lng, p.lat]).toList(),
            },
          },
        ],
      };

      final sources = await mapboxMap!.style.getStyleSources();
      final layers = await mapboxMap!.style.getStyleLayers();

      if (!sources.any((s) => s?.id == 'route_source')) {
        await mapboxMap!.style.addSource(
          GeoJsonSource(
            id: 'route_source',
            data: jsonEncode(featureCollection),
          ),
        );
      }

      if (!layers.any((l) => l?.id == 'route_outline_layer')) {
        await mapboxMap!.style.addLayerAt(
          LineLayer(
            id: 'route_outline_layer',
            sourceId: 'route_source',
            lineColor: TColors.primary.toARGB32(),
            lineWidth: 12.0,
            lineCap: LineCap.ROUND,
            lineJoin: LineJoin.ROUND,
          ),
          LayerPosition(below: 'highway-name-minor'),
        );
      }

      if (!layers.any((l) => l?.id == 'route_layer')) {
        await mapboxMap!.style.addLayerAt(
          LineLayer(
            id: 'route_layer',
            sourceId: 'route_source',
            lineColor: TColors.accent.toARGB32(),
            lineWidth: 8.0,
            lineCap: LineCap.ROUND,
            lineJoin: LineJoin.ROUND,
          ),
          LayerPosition(below: 'highway-name-minor'),
        );
      }

      await loadRouteIcons();

      if (!sources.any((s) => s?.id == 'route_markers')) {
        await mapboxMap!.style.addSource(
          GeoJsonSource(
            id: 'route_markers',
            data: jsonEncode({
              "type": "FeatureCollection",
              "features": [
                {
                  "type": "Feature",
                  "geometry": {
                    "type": "Point",
                    "coordinates": [positions.first.lng, positions.first.lat],
                  },
                  "properties": {"icon": "route_start_icon"},
                },
                {
                  "type": "Feature",
                  "geometry": {
                    "type": "Point",
                    "coordinates": [positions.last.lng, positions.last.lat],
                  },
                  "properties": {"icon": "route_end_icon"},
                },
              ],
            }),
          ),
        );
      }

      if (!layers.any((l) => l?.id == 'route_markers_layer')) {
        await mapboxMap!.style.addLayerAt(
          SymbolLayer(
            id: 'route_markers_layer',
            sourceId: 'route_markers',
            iconImageExpression: ["get", "icon"],
            iconSize: 0.02,
            iconAllowOverlap: false,
            iconIgnorePlacement: false,
          ),
          LayerPosition(below: 'highway-name-minor'),
        );
      }

      if (!sources.any((s) => s?.id == 'route_arrows')) {
        await mapboxMap!.style.addSource(
          GeoJsonSource(
            id: 'route_arrows',
            data: jsonEncode(arrowFeatureCollection),
          ),
        );
      }

      if (!layers.any((l) => l?.id == 'route_arrows_layer')) {
        await mapboxMap!.style.addLayerAt(
          SymbolLayer(
            id: 'route_arrows_layer',
            sourceId: 'route_arrows',
            iconImage: 'step_arrow_icon',
            iconRotateExpression: ["get", "bearing"],
            iconAllowOverlap: true,
            iconIgnorePlacement: true,
            iconSize: 0.05,
          ),
          LayerPosition(below: 'route_markers_layer'),
        );
      }

      await initUserMarker(positions);
      await updateUserMarker(
        positions.first.lat as double,
        positions.first.lng as double,
      );
      final userBearing = calculateBearing(positions[0], positions[1]);
      await mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(positions.first.lng, positions.first.lat),
          ),
          zoom: 19,
          pitch: 60,
          bearing: userBearing,
        ),
        MapAnimationOptions(duration: 1500),
      );
    } catch (e) {
      debugPrint('❌ Failed to start virtual escort: $e');
    }
  }

  double calculateBearing(Position from, Position to) {
    final lat1 = from.lat * (pi / 180);
    final lon1 = from.lng * (pi / 180);
    final lat2 = to.lat * (pi / 180);
    final lon2 = to.lng * (pi / 180);

    final dLon = lon2 - lon1;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  Future<List<RouteStepModel>> parseRouteSteps(String responseBody) async {
    final data = jsonDecode(responseBody);
    final stepsJson = data['routes'][0]['legs'][0]['steps'] as List<dynamic>;
    return stepsJson.map((s) => RouteStepModel.fromJson(s)).toList();
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000;
    final dLat = (lat2 - lat1) * (3.141592653589793 / 180);
    final dLng = (lng2 - lng1) * (3.141592653589793 / 180);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
            cos(lat1 * (3.141592653589793 / 180)) *
                cos(lat2 * (3.141592653589793 / 180)) *
                (sin(dLng / 2) * sin(dLng / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> startTrackingWithInstructions(List<RouteStepModel> steps) async {
    await preloadSpeedLimits(steps);
    int currentStepIndex = 0;
    Position? lastPosition;
    double minDistanceToStep = double.infinity;

    positionStream =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.bestForNavigation,
            distanceFilter: 1,
          ),
        ).listen((gps) async {
          try {
            final currentPos = Position.named(
              lat: gps.latitude,
              lng: gps.longitude,
            );

            double speed = gps.speed;
            double factor = (speed / 10).clamp(0.2, 0.8);
            final userPos = lastPosition == null
                ? currentPos
                : Position.named(
              lat:
              lastPosition!.lat * (1 - factor) +
                  currentPos.lat * factor,
              lng:
              lastPosition!.lng * (1 - factor) +
                  currentPos.lng * factor,
            );
            lastPosition = userPos;

            if (currentStepIndex >= steps.length) return;

            final currentStep = steps[currentStepIndex];

            // Calculate distance to current step's end point
            final distanceToEnd = calculateDistance(
              userPos.lat as double,
              userPos.lng as double,
              currentStep.endLat,
              currentStep.endLng,
            );

            // NEW: Calculate bearing to check if user is moving toward the point
            final userBearing = lastPosition != null
                ? calculateBearing(lastPosition!, userPos)
                : null;

            final bearingToStep = calculateBearing(
              userPos,
              Position.named(lat: currentStep.endLat, lng: currentStep.endLng),
            );

            // NEW: Check if user has passed the step point
            final hasPassed = _checkIfPassedStep(
              userPos,
              currentStep,
              userBearing,
              bearingToStep,
            );

            // NEW: Update minimum distance tracking
            if (distanceToEnd < minDistanceToStep) {
              minDistanceToStep = distanceToEnd;
            }

            currentInstruction.value = currentStep.instruction;
            distanceToNext.value = '${distanceToEnd.toStringAsFixed(0)} m';
            speedLimit.value =
                currentStep.speedLimit?.toStringAsFixed(0) ?? '--';

            // NEW: Improved step progression logic
            if (_shouldAdvanceToNextStep(
              distanceToEnd,
              hasPassed,
              minDistanceToStep,
              userBearing,
              bearingToStep,
            )) {
              _advanceToNextStep(steps, currentStepIndex);
              currentStepIndex++;

              // Reset tracking variables for the new step
              minDistanceToStep = double.infinity;
              _lastStepUpdateTime = DateTime.now();
            }
          } catch (e) {
            debugPrint('⚠️ Instruction tracking error: $e');
          }
        });
  }

  void _advanceToNextStep(List<RouteStepModel> steps, int currentIndex) {
    if (currentIndex + 1 < steps.length) {
      final nextStep = steps[currentIndex + 1];
      debugPrint('➡️ Next instruction: ${nextStep.instruction}');
      debugPrint(
        '📏 Distance to next: ${calculateDistance(steps[currentIndex].endLat, steps[currentIndex].endLng, nextStep.endLat, nextStep.endLng).toStringAsFixed(0)} m',
      );
    } else {
      debugPrint('🎉 Route completed!');
    }
  }

  Future<void> loadRouteAndStartTracking(String responseBody) async {
    final steps = await parseRouteSteps(responseBody);
    startTrackingWithInstructions(steps);
  }

  bool checkDestinationReached(Position currentPosition, List<Position> routePositions) {
    if (routePositions.isEmpty) return false;
    final destination = routePositions.last;
    final distance = _calculateDistance(currentPosition, destination);
    return distance < 20.0;
  }

  void startUserTrackingAlongRoute(List<Position> routePositions) {
    positionStream =
        geo.Geolocator.getPositionStream(
          locationSettings: const geo.LocationSettings(
            accuracy: geo.LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((gps) async {
          if (gpsHistory.isNotEmpty) {
            final lastPos = gpsHistory.last;
            final distance = _calculateDistance(
              lastPos,
              Position.named(lat: gps.latitude, lng: gps.longitude),
            );
            if (distance < 2.0) return;
          }
          gpsHistory.add(Position.named(lat: gps.latitude, lng: gps.longitude));
          if (gpsHistory.length > 10) gpsHistory.removeAt(0);
          latestSpeed = gps.speed;
          lastGpsPosition = currentInterpolated ?? gpsHistory.last;
          nextGpsPosition = gpsHistory.last;

          // if (routePositions.isNotEmpty) {
          //   await checkUserOffRoute(gps, routePositions);
          // }

          if (lastGpsTime != null) {
            expectedTravelTime =
                DateTime.now().difference(lastGpsTime!).inMilliseconds / 1000.0;
          } else {
            expectedTravelTime = 1.0;
          }
          lastGpsTime = DateTime.now();

          final currentPos = Position.named(lat: gps.latitude, lng: gps.longitude);
          if (checkDestinationReached(currentPos, routePositions) && !hasArrived.value) {
            hasArrived.value = true;
            positionStream?.cancel();
            trackingTimer?.cancel();

            if (Get.isRegistered<VirtualEscortJourneyStartScreen>()) {
              Get.find<VirtualEscortJourneyStartScreen>().showDestinationReachedDialog();
            }
          }
        });

    trackingTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) async {
      if (lastGpsPosition == null || nextGpsPosition == null || lastGpsTime == null) return;

      final latestGps = gpsHistory.last;
      final distanceSinceLastNext = _calculateDistance(nextGpsPosition!, latestGps);
      if (distanceSinceLastNext > gpsUpdateThreshold) {
        lastGpsPosition = currentInterpolated ?? nextGpsPosition!;
        nextGpsPosition = latestGps;
        lastGpsTime = DateTime.now();
      }

      final now = DateTime.now();
      final dt = now.difference(lastGpsTime!).inMilliseconds / 1000.0;
      final travelTime = expectedTravelTime ?? 1.0;
      final t = (dt / travelTime).clamp(0.0, 1.0);

      final easedT = pow(t, 0.7).toDouble();
      final lat = lastGpsPosition!.lat * (1 - easedT) + nextGpsPosition!.lat * easedT;
      final lng = lastGpsPosition!.lng * (1 - easedT) + nextGpsPosition!.lng * easedT;
      final interpolated = Position.named(lat: lat, lng: lng);

      // Always update the marker position for smooth movement
      await updateUserMarker(lat, lng);

      // Only update camera if moved enough
      if (_lastMarkerPosition == null ||
          _calculateDistance(_lastMarkerPosition!, interpolated) > markerMoveThreshold) {
        _lastMarkerPosition = interpolated;

        double targetBearing = getLookaheadBearing(gpsHistory, 2);
        smoothedBearing ??= targetBearing;
        double diff = (((targetBearing - smoothedBearing!) + 540) % 360) - 180;
        double lerpFactor = (0.1 + (diff.abs() / 180) * 0.4).clamp(0.1, 0.6);
        smoothedBearing = interpolateBearing(smoothedBearing!, targetBearing, lerpFactor);

        await mapboxMap!.setCamera(
          CameraOptions(
            center: Point(coordinates: interpolated),
            zoom: 18,
            bearing: smoothedBearing,
            pitch: 50,
            padding: MbxEdgeInsets(top: 450, left: 0, bottom: 50, right: 0),
          ),
        );
      }

      currentInterpolated = interpolated;
    });
  }

  bool _checkIfPassedStep(
      Position userPos,
      RouteStepModel step,
      double? userBearing,
      double bearingToStep,
      ) {
    if (userBearing == null) return false;

    // Calculate if user is moving away from the point
    final bearingDiff = ((userBearing - bearingToStep) + 540) % 360 - 180;
    final isMovingAway = bearingDiff.abs() > 90; // More than 90° difference

    // Check if user is beyond the point in their direction of travel
    final distance = calculateDistance(
      userPos.lat as double,
      userPos.lng as double,
      step.endLat,
      step.endLng,
    );

    return isMovingAway && distance < 50; // Moving away and within 50m
  }

  bool _shouldAdvanceToNextStep(
      double distanceToEnd,
      bool hasPassed,
      double minDistance,
      double? userBearing,
      double bearingToStep,
      ) {
    // Option 1: Very close to the point (original logic)
    if (distanceToEnd < 15) {
      return true;
    }

    // Option 2: User has clearly passed the point
    if (hasPassed) {
      return true;
    }

    // Option 3: User reached closest point and is now moving away
    if (minDistance < 25 && distanceToEnd > minDistance + 10) {
      return true;
    }

    // Option 4: Time-based fallback (prevent getting stuck)
    if (_lastStepUpdateTime != null) {
      final timeSinceLastUpdate = DateTime.now().difference(
        _lastStepUpdateTime!,
      );
      if (timeSinceLastUpdate.inSeconds > 30 && distanceToEnd < 50) {
        return true; // Force advance after 30 seconds if reasonably close
      }
    }

    // Option 5: Bearing-based detection for highways/fast roads
    if (userBearing != null) {
      final bearingDiff = ((userBearing - bearingToStep) + 540) % 360 - 180;
      if (bearingDiff.abs() > 120 && distanceToEnd < 100) {
        return true; // Moving in very different direction but was close
      }
    }

    return false;
  }

  double _calculateDistance(Position pos1, Position pos2) {
    final lat1 = pos1.lat * pi / 180.0;
    final lon1 = pos1.lng * pi / 180.0;
    final lat2 = pos2.lat * pi / 180.0;
    final lon2 = pos2.lng * pi / 180.0;

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadius * c;
  }

  double getLookaheadBearing(List<Position> history, int lookahead) {
    if (history.length < 2) return smoothedBearing ?? 0.0;
    final from = history[history.length - 2];
    final to = history.last;
    var bearing = calculateBearing(from, to);
    int futureIndex = history.length - 1 + lookahead;
    if (futureIndex < history.length) {
      final current = history.last;
      final lookaheadPoint = history[futureIndex];
      bearing = calculateBearing(current, lookaheadPoint);
    }
    return bearing;
  }

  double interpolateBearing(double from, double to, double factor) {
    double diff = ((to - from + 540) % 360) - 180;
    return (from + diff * factor + 360) % 360;
  }

  Future<void> initUserMarker(List<Position> initialPositions) async {
    try {
      final startPos = initialPositions.isNotEmpty
          ? initialPositions.first
          : Position(0, 0);


      final imageData = await getImage(TImages.navigationRouteIcon);
      await mapboxMap!.style.addStyleImage(
        'navigation-icon',
        1.0,
        imageData,
        false,
        [],
        [],
        null,
      );

      final initialFeature = {
        "type": "Feature",
        "id": "user_marker",
        "geometry": {
          "type": "Point",
          "coordinates": [startPos.lng, startPos.lat],
        },
        "properties": {
          "bearing": 0,
        },
      };

      final sources = await mapboxMap!.style.getStyleSources();
      if (sources.any((s) => s?.id == 'navigation-marker-source')) {
        await mapboxMap!.style.updateGeoJSONSourceFeatures(
          'navigation-marker-source',
          'marker_init',
          [Feature.fromJson(initialFeature)],
        );
      } else {
        await mapboxMap!.style.addSource(
          GeoJsonSource(
            id: 'navigation-marker-source',
            data: jsonEncode({
              "type": "FeatureCollection",
              "features": [initialFeature],
            }),
          ),
        );
      }

      final layers = await mapboxMap!.style.getStyleLayers();
      if (!layers.any((l) => l?.id == 'navigation-marker-layer')) {
        await mapboxMap!.style.addLayer(
          SymbolLayer(
            id: 'navigation-marker-layer',
            sourceId: 'navigation-marker-source',
            iconImage: 'navigation-icon',
            iconSize: 0.65,
            iconRotateExpression: ['get', 'bearing'],
            iconAnchor: IconAnchor.BOTTOM,
            iconPitchAlignment: IconPitchAlignment.MAP,
            iconRotationAlignment: IconRotationAlignment.MAP,
            iconIgnorePlacement: true,
            iconAllowOverlap: true,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize user marker: $e');
    }
  }

  Future<void> updateUserMarker(double lat, double lng) async {
    try {
      final cameraState = await mapboxMap!.getCameraState();
      final bearing = cameraState.bearing;
      debugPrint('📍 Updating marker to: $lat, $lng with bearing: $bearing');

      final updatedFeature = Feature(
        geometry: Point(coordinates: Position(lng, lat)),
        properties: {
          "bearing": bearing,
        }, id: "user_marker",
      );

      await mapboxMap!.style.updateGeoJSONSourceFeatures(
        'navigation-marker-source',
        'user_marker_update',
        [updatedFeature],
      );

      debugPrint('✅ Marker updated successfully');
    } catch (e) {
      debugPrint('❌ Failed to update user marker: $e');
      final sources = await mapboxMap!.style.getStyleSources();
      final sourceExists = sources.any((s) => s?.id == 'navigation-marker-source');
      debugPrint('Source exists: $sourceExists');
    }
  }

  Future<double?> fetchSpeedLimit(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://speedlimit.goong.io/api/v1/speedlimit?lat=$lat&lon=$lng&api_key=$goongApiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['speedLimit'] as num?)?.toDouble();
      }
    } catch (e) {
      debugPrint('⚠️ Speed limit fetch error: $e');
    }
    return null;
  }

  Future<void> preloadSpeedLimits(List<RouteStepModel> steps) async {
    for (var step in steps) {
      step.speedLimit = await fetchSpeedLimit(step.startLat, step.startLng);
    }
  }

  // Future<void> checkUserOffRoute(geo.Position gps, List<Position> routePositions) async {
  //   if (hasArrived.value) return;
  //   double minDistance = double.infinity;
  //   Position nearestPoint = routePositions.first;
  //   for (final point in routePositions) {
  //     final distance = _calculateDistance(
  //         Position.named(lat: gps.latitude, lng: gps.longitude),
  //         point
  //     );
  //
  //     if (distance < minDistance) {
  //       minDistance = distance;
  //       nearestPoint = point;
  //     }
  //   }
  //   final destination = routePositions.last;
  //   final distanceToDestination = _calculateDistance(
  //       Position.named(lat: gps.latitude, lng: gps.longitude),
  //       destination
  //   );
  //
  //   if (distanceToDestination <= 20.0) return;
  //
  //   if (minDistance > 200) {
  //     positionStream?.cancel();
  //     trackingTimer?.cancel();
  //     Get.off(() => VirtualEscortSosScreen());
  //   }
  // }

  Future<void> loadObserverJourney(int memberId) async {
    try {
      final data = await escortService.getJourneyForObserver(memberId);
      if (data == null) return;
      final overviewPolyline = data['routes'][0]['overview_polyline']['points'];
      final List<Position> positions = _decodePolylineToPositions(overviewPolyline);

      final featureCollection = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "id": "observer_route",
            "properties": {},
            "geometry": {
              "type": "LineString",
              "coordinates": positions.map((p) => [p.lng, p.lat]).toList(),
            },
          },
        ],
      };

      await mapboxMap!.style.addSource(
        GeoJsonSource(id: "observer_route_source", data: jsonEncode(featureCollection)),
      );

      await mapboxMap!.style.addLayerAt(
        LineLayer(
          id: 'observer_route_layer_outline',
          sourceId: 'observer_route_source',
          lineColor: TColors.primary.toARGB32(),
          lineWidth: 12.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
        LayerPosition(below: 'highway-name-minor'),
      );

      await mapboxMap!.style.addLayerAt(
        LineLayer(
          id: "observer_route_layer",
          sourceId: "observer_route_source",
          lineColor: TColors.accent.toARGB32(),
          lineWidth: 8.0,
          lineCap: LineCap.ROUND,
          lineJoin: LineJoin.ROUND,
        ),
        LayerPosition(below: "highway-name-minor"),
      );

      await mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(positions.first.lng, positions.first.lat),
          ),
          zoom: 18,
        ),
        MapAnimationOptions(duration: 1500),
      );

      debugPrint("✅ Observer route loaded with ${positions.length} points");
    } catch (e) {
      debugPrint("❌ Failed to load observer journey: $e");
    }
  }

  Future<void> createEscortAfterRoute({
    required int groupId,
    String vehicle = "bike",
    List<int> watcherIds = const [],
    required Map<dynamic, dynamic> rawJson,
  }) async {
    try {
      final result = await escortService.createVirtualEscort(
        groupId: groupId,
        rawJson: jsonEncode(rawJson),
        vehicle: vehicle,
        watcherIds: watcherIds,
      );

      if (result["success"] == true) {
        debugPrint("✅ Escort created: ${result["data"]}");
      } else {
        debugPrint("❌ Failed to create escort: ${result["message"]}");
      }
    } catch (e) {
      debugPrint("❌ Exception in createEscortAfterRoute: $e");
    }
  }

  Future<void> updateObserverMarker(double lat, double lng) async {
    if (mapboxMap == null) {
      debugPrint("⚠️ mapboxMap is null, cannot update observer marker");
      return;
    }
    final imageBytes = await getImageFromAsset(TImages.observerLocationPuck);

    if (_markerManager == null) {
      await _recreateMarkerManager();
    }
    if (_markerManager == null) {
      debugPrint("❌ Failed to create marker manager for observer marker");
      return;
    }

    final point = Point(coordinates: Position(lng, lat));

    try {
      if (_observerMarker == null) {
        _observerMarker = await _markerManager!.create(
          PointAnnotationOptions(
            geometry: point,
            image: imageBytes,
            iconSize: 0.06,
          ),
        );
        debugPrint("✅ Observer marker created at $lat,$lng");
      } else {
        _observerMarker!.geometry = point;
        await _markerManager!.update(_observerMarker!);
        debugPrint("🔄 Observer marker updated to $lat,$lng");
      }
      await mapboxMap!.flyTo(
        CameraOptions(center: point, zoom: 17),
        MapAnimationOptions(duration: 1000),
      );
    } catch (e) {
      debugPrint("❌ Failed to update observer marker: $e");
    }
  }
}
