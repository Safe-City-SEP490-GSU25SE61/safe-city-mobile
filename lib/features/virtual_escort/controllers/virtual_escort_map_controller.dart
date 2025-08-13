import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
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
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../models/goong_prediction_model.dart';

class VirtualEscortMapController extends GetxController {
  static VirtualEscortMapController get instance => Get.find();
  MapboxMap? mapboxMap;
  PointAnnotationManager? _customMarkerManager;
  final goongMapTilesKey = dotenv.env['GOONG_MAP_TILES_KEY2']!;
  final goongApiKey = dotenv.env['GOONG_API_KEY3']!;
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
  Timer? locationUpdateTimer;
  late PointAnnotationManager _pointAnnotationManager;
  PointAnnotation? _userMarker;

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
        message: 'Vị trí đã bị từ chối vĩnh viễn. Vui lòng bật quyền trong cài đặt.',
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
        'https://rsapi.goong.io/v2/place/autocomplete?input=$input&location=$userLat,$userLng&limit=1&has_deprecated_administrative_unit=false&api_key=$goongApiKey';

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
      await _removeRouteLayersAndSource();

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
      final polyline =
          data['routes'][0]['overview_polyline']['points'] as String;
      final List<Position> positions = _decodePolylineToPositions(polyline);

      await secureStorage.write(key: 'escort_polyline', value: polyline);

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
          zoom: 19,
        ),
        MapAnimationOptions(duration: 1500),
      );
      return positions;
    } catch (e) {
      debugPrint('❌ Failed to load route: $e');
      return [];
    }
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
    await initUserMarker();
    final storage = const FlutterSecureStorage();
    final polyline = await storage.read(key: 'escort_polyline');
    if (polyline != null) {
      final positions = _decodePolylineToPositions(polyline);
      startUserTrackingAlongRoute(positions);
    }

    if (originPosition.value != null && destinationPosition.value != null) {
      await mapDirectionRoute(
        originLat: originPosition.value!.lat.toDouble(),
        originLng: originPosition.value!.lng.toDouble(),
        destLat: destinationPosition.value!.lat.toDouble(),
        destLng: destinationPosition.value!.lng.toDouble(),
      );
    }
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

      final storage = const FlutterSecureStorage();
      final polyline = await storage.read(key: 'escort_polyline');
      if (polyline == null) {
        debugPrint('⚠️ No saved polyline found');
        return;
      }

      final positions = _decodePolylineToPositions(polyline);

      await _removeRouteLayersAndSource();

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

  void startUserTrackingAlongRoute(List<Position> routePositions) {
    double? lastBearing;
    Position? lastSnappedPosition;

    locationUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          locationUpdateTimer?.cancel();
          return TLoaders.warningSnackBar(
            title: 'Lỗi',
            message: 'Vui lòng bật định vị GPS để tiếp tục hành trình.',
          );
        }

        final gpsPosition = await geo.Geolocator.getCurrentPosition();

        final snappedPosition = snapToRoute(
          Position.named(lat: gpsPosition.latitude, lng: gpsPosition.longitude),
          routePositions,
        );

        final nextIndex = routePositions.indexOf(snappedPosition) + 1;
        final targetBearing = (nextIndex < routePositions.length)
            ? calculateBearing(snappedPosition, routePositions[nextIndex])
            : (lastBearing ?? 0.0);

        final smoothBearing = lastBearing == null
            ? targetBearing
            : (lastBearing! * 0.8 + targetBearing * 0.2);
        lastBearing = smoothBearing;

        final interpolatedPosition = lastSnappedPosition == null
            ? snappedPosition
            : Position.named(
          lat: lastSnappedPosition!.lat * 0.6 + snappedPosition.lat * 0.4,
          lng: lastSnappedPosition!.lng * 0.6 + snappedPosition.lng * 0.4,
        );
        lastSnappedPosition = interpolatedPosition;

        await mapboxMap!.easeTo(
          CameraOptions(
            center: Point(coordinates: interpolatedPosition),
            zoom: 18,
            bearing: smoothBearing,
            pitch: 50,
            padding: MbxEdgeInsets(top: 450, left: 0, bottom: 50, right: 0),
          ),
          MapAnimationOptions(duration: 1500),
        );

        if (_userMarker != null) {
          _userMarker!.geometry = Point(
            coordinates: Position(interpolatedPosition.lng, interpolatedPosition.lat),
          );
          await _pointAnnotationManager.update(_userMarker!);
        }
      } catch (e) {
        debugPrint('⚠️ Tracking error: $e');
      }
    });

    // List<Position> testPositions = [
    //   Position.named(lat: 10.845696149299554, lng: 106.68034845575994),
    //   Position.named(lat: 10.845686929256455, lng: 106.68025524900244),
    //   Position.named(lat: 10.845685612107415, lng: 106.6802203802874),
    //   Position.named(lat: 10.845690222129015, lng: 106.68020026372103),
    //   Position.named(lat: 10.845744225233922, lng: 106.68015868948387),
    //   Position.named(lat: 10.84582391272455, lng: 106.68013186739537),
    //   Position.named(lat: 10.845878574379409, lng: 106.68009901033697),
    //   Position.named(lat: 10.845943773207678, lng: 106.68007554100956),
    //   Position.named(lat: 10.84598394621599, lng: 106.68004737781662),
    //   Position.named(lat: 10.846037290697192, lng: 106.6800098268889),
    //   Position.named(lat: 10.846065609366898, lng: 106.67998233424821),
    //   Position.named(lat: 10.846078780840259, lng: 106.67997361706945),
    //   Position.named(lat: 10.846085366576727, lng: 106.67995819436857),
    //   Position.named(lat: 10.846067585087939, lng: 106.67993472504115),
    //   Position.named(lat: 10.846037949270936, lng: 106.67990320908717),
    //   Position.named(lat: 10.846010947746224, lng: 106.67984956491017),
    //   Position.named(lat: 10.84592467456224, lng: 106.6797483115088),
    //   Position.named(lat: 10.845851572840065, lng: 106.67968125628757),
    //   Position.named(lat: 10.845817985556316, lng: 106.67963565873715),
    //   Position.named(lat: 10.845764641039096, lng: 106.67949551332478),
    //   Position.named(lat: 10.845727102295964, lng: 106.67940632985807),
    //   Position.named(lat: 10.845694832147231, lng: 106.67934061574127),
    //   Position.named(lat: 10.845596045956029, lng: 106.67914213228643),
    //   Position.named(lat: 10.845519055783306, lng: 106.67896936737557),
    //   Position.named(lat: 10.845490078486895, lng: 106.67885403239507),
    //   Position.named(lat: 10.845345191962762, lng: 106.678588493719),
    //   Position.named(lat: 10.845326751854659, lng: 106.6785294851243),
    //   Position.named(lat: 10.845210842577663, lng: 106.67849998082697),
    //   Position.named(lat: 10.844992195397356, lng: 106.67842487894059),
    //   Position.named(lat: 10.844676078727957, lng: 106.67836318813706),
    //   Position.named(lat: 10.844428453770222, lng: 106.6782719930362),
    //   Position.named(lat: 10.844046478682301, lng: 106.67818616231781),
    //   Position.named(lat: 10.843798853203301, lng: 106.67806814512846),
    //   Position.named(lat: 10.843656600175862, lng: 106.67800377211609),
    //   Position.named(lat: 10.84327989275787, lng: 106.67779992424356),
    //   Position.named(lat: 10.843042803909183, lng: 106.67768727143154),
    //   Position.named(lat: 10.842766200039025, lng: 106.67745660147051),
    //   Position.named(lat: 10.842616043545256, lng: 106.67737613520502),
    //   Position.named(lat: 10.842397394480939, lng: 106.67722593150948),
    //   Position.named(lat: 10.842168207940782, lng: 106.67713205419976),
    //   Position.named(lat: 10.841875797272566, lng: 106.67698989713075),
    //   Position.named(lat: 10.84177013935299, lng: 106.67694037572836),
    //   Position.named(lat: 10.841755650523549, lng: 106.67691623584872),
    //   Position.named(lat: 10.84177409085181, lng: 106.67685052173191),
    //   Position.named(lat: 10.841812288671012, lng: 106.67679955976378),
    //   Position.named(lat: 10.84187024397361, lng: 106.67671909349829),
    //   Position.named(lat: 10.84191766194009, lng: 106.6766372861284),
    //   Position.named(lat: 10.841967714224777, lng: 106.67656084314135),
    //   Position.named(lat: 10.841832046156647, lng: 106.67650719896437),
    //   Position.named(lat: 10.84169110935291, lng: 106.67646294250582),
    //   Position.named(lat: 10.841378940698972, lng: 106.67636772409168),
    // ];
    // int testIndex = 0;
    // locationUpdateTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
    //   // Instead of real GPS:
    //   final gpsPosition = testPositions[testIndex];
    //   testIndex = (testIndex + 1) % testPositions.length; // loop through
    //
    //   final snappedPosition = snapToRoute(gpsPosition, routePositions);
    //   final nextIndex = routePositions.indexOf(snappedPosition) + 1;
    //
    //   final bearing = (nextIndex < routePositions.length)
    //       ? calculateBearing(snappedPosition, routePositions[nextIndex])
    //       : (lastBearing ?? 0.0);
    //
    //   final smoothBearing = lastBearing == null
    //       ? bearing
    //       : (bearing + lastBearing!) / 2;
    //
    //   lastBearing = smoothBearing;
    //
    //   await mapboxMap!.easeTo(
    //     CameraOptions(
    //       center: Point(
    //         coordinates: Position.named(
    //           lat: snappedPosition.lat,
    //           lng: snappedPosition.lng,
    //         ),
    //       ),
    //       zoom: 18,
    //       bearing: smoothBearing,
    //       pitch: 60,
    //     ),
    //     MapAnimationOptions(duration: 1200),
    //   );
    //
    //   if (_userMarker != null) {
    //     _userMarker!.geometry = Point(
    //       coordinates: Position(snappedPosition.lng, snappedPosition.lat),
    //     );
    //     await _pointAnnotationManager.update(_userMarker!);
    //   }
    // });
  }

  Position snapToRoute(Position gpsPosition, List<Position> route) {
    Position closestPoint = route.first;
    double closestDistance = double.infinity;

    for (final point in route) {
      final distance = geo.Geolocator.distanceBetween(
        gpsPosition.lat.toDouble(),
        gpsPosition.lng.toDouble(),
        point.lat.toDouble(),
        point.lng.toDouble(),
      );
      if (distance < closestDistance) {
        closestDistance = distance;
        closestPoint = point;
      }
    }
    return closestPoint;
  }

  Future<void> initUserMarker() async {
    final bytes = await rootBundle.load(TImages.navigationRouteIcon);
    final imageData = bytes.buffer.asUint8List();

    _pointAnnotationManager = await mapboxMap!.annotations
        .createPointAnnotationManager();

    final cameraState = await mapboxMap!.getCameraState();
    final bearing = cameraState.bearing;

    _userMarker = await _pointAnnotationManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(0, 0)),
        image: imageData,
        iconSize: 2.0,
        iconRotate: bearing,
      ),
    );
  }

  Future<void> updateUserMarker(double lat, double lng) async {
    if (_userMarker != null) {
      _userMarker!.geometry = Point(coordinates: Position(lng, lat));
      await _pointAnnotationManager.update(_userMarker!);
    }
  }
}
