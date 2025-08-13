import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import '../../../data/services/live_map_incident/live_map_incident_service.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/popups/loaders.dart';
import '../models/goong_prediction_model.dart';
import '../models/live_map_report_detail_model.dart';
import '../screens/widgets/commune_overview_widget.dart';
import '../screens/widgets/commune_report_detail_widget.dart';

class IncidentLiveMapController extends GetxController {
  MapboxMap? mapboxMap;
  PointAnnotationManager? _customMarkerManager;
  MbxImage? _cachedOverviewIcon;
  final goongMapTilesKey= dotenv.env['GOONG_MAP_TILES_KEY1']!;
  final goongApiKey = dotenv.env['GOONG_API_KEY1']!;
  final searchController = TextEditingController();
  final liveMapService = LiveMapIncidentService();
  final RxBool isLoading = false.obs;
  final RxBool isOverviewLoading = false.obs;
  final RxBool isFocusedOnCommune = false.obs;
  final RxBool isExitingCommuneFocus = false.obs;
  final RxBool isCommuneReportFocusLoading = false.obs;
  Timer? _debounceTimer;
  final RxList<GoongPredictionModel> predictions = <GoongPredictionModel>[].obs;
  final RxInt traffic = 0.obs;
  final RxInt security = 0.obs;
  final RxInt infrastructure = 0.obs;
  final RxInt environment = 0.obs;
  final RxInt other = 0.obs;
  String? selectedFilterStatus;
  String? selectedFilterTime;
  String get selectedTypeApi => convertStatusToApiValue(selectedFilterStatus);
  String get selectedRangeApi => convertTimeToApiRange(selectedFilterTime);
  final RxString selectedRange = 'week'.obs;
  Map<String, dynamic>? lastFocusedCommuneFeature;
  void enableCommuneFocus() => isFocusedOnCommune.value = true;
  void disableCommuneFocus() => isFocusedOnCommune.value = false;
  final Map<String, ReportDetailModel> reportMap = {};


  @override
  void onClose() {
    mapboxMap = null;
    _customMarkerManager = null;
    super.onClose();
  }

  void debounceLoadPolygons({Duration duration = const Duration(milliseconds: 800),}) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, () {
      loadPolygonsFromAPI();
    });
  }

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
        "https://tiles.goong.io/assets/goong_light_v2.json?$goongMapTilesKey";
    final lightStyle =
        "https://tiles.goong.io/assets/goong_light_v2.json?$goongMapTilesKey";

    mapboxMap!.loadStyleURI(isDarkMode ? darkStyle : lightStyle).then((
      _,
    ) async {
      await loadPolygonsFromAPI();
    });

    await mapboxMap!.setBounds(
      CameraBoundsOptions(minZoom: 13.0, maxZoom: 20.0),
    );

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
    final loc =
        await geo.Geolocator.getLastKnownPosition() ??
        await geo.Geolocator.getCurrentPosition();

    final userLat = loc.latitude;
    final userLng = loc.longitude;

    final acUrl =
        'https://rsapi.goong.io/v2/place/autocomplete'
        '?input=$input'
        '&location=$userLat,$userLng'
        '&limit=5&api_key=$goongApiKey'
        '&more_compound=true'
        '&has_deprecated_administrative_unit=false';

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
                  'https://rsapi.goong.io/v2/place/detail?place_id=${p.placeId}&api_key=$goongApiKey',
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

  Future<void> selectPlace(String placeId) async {
    final url =
        'https://rsapi.goong.io/v2/place/detail?place_id=$placeId&api_key=$goongApiKey';
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
        CameraOptions(center: point, zoom: 14, bearing: 0, pitch: 0),
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

    if (_customMarkerManager != null) {
      try {
        await _customMarkerManager!.deleteAll();
      } catch (e) {
        debugPrint('⚠️ Failed to delete annotations: $e');
      }
    }

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

  Future<MbxImage> getOverviewIcon() async {
    if (_cachedOverviewIcon != null) return _cachedOverviewIcon!;
    _cachedOverviewIcon = await getImage(TImages.communesOverviewIcon);
    return _cachedOverviewIcon!;
  }

  Future<MbxImage> getImage(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return await _decodeImage(bytes.buffer.asUint8List());
  }

  Future<MbxImage> _decodeImage(Uint8List bytes) async {
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData == null) {
      throw Exception("Failed to convert image to byte data");
    }

    return MbxImage(
      data: byteData.buffer.asUint8List(),
      width: image.width,
      height: image.height,
    );
  }

  Future<void> loadPolygonsFromAPI() async {
    isLoading.value = true;

    try {
      final rawDataList = await liveMapService.fetchCommunesPolygon();
      final markerIcon = await getOverviewIcon();

      final List<Map<String, dynamic>> polygonFeatures = [];
      final List<Map<String, dynamic>> markerFeatures = [];

      for (var collection in rawDataList) {
        final features = collection['features'] as List<dynamic>;

        for (var feature in features) {
          final geometry = feature['geometry'];
          final type = geometry['type'];
          final properties = feature['properties'];

          if (type == 'Polygon' || type == 'MultiPolygon') {
            polygonFeatures.add({
              "type": "Feature",
              "geometry": geometry,
              "properties": properties,
            });
          } else if (type == 'Point') {
            final coords = geometry['coordinates'];
            final lng = coords[0].toDouble();
            final lat = coords[1].toDouble();

            markerFeatures.add({
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [lng, lat],
              },
              "properties": properties,
            });
          } else {
            if (kDebugMode) {
              print('❌ Unknown geometry type: $type');
            }
          }
        }
      }

      final style = mapboxMap!.style;

      final polygonSourceId = "commune-source";
      final fillLayerId = "commune-fill-layer";
      final lineLayerId = "commune-outline-layer";

      final markerSourceId = "incident-marker-source";
      final markerLayerId = "incident-marker-layer";

      try {
        await style.removeStyleLayer(fillLayerId);
      } catch (_) {}
      try {
        await style.removeStyleLayer(lineLayerId);
      } catch (_) {}
      try {
        await style.removeStyleSource(polygonSourceId);
      } catch (_) {}

      try {
        await style.removeStyleLayer(markerLayerId);
      } catch (_) {}
      try {
        await style.removeStyleSource(markerSourceId);
      } catch (_) {}

      /// Add polygon source and layers
      await style.addSource(
        GeoJsonSource(
          id: polygonSourceId,
          data: jsonEncode({
            "type": "FeatureCollection",
            "features": polygonFeatures,
          }),
        ),
      );

      await style.addLayer(
        FillLayer(
          id: fillLayerId,
          sourceId: polygonSourceId,
          fillColor: TColors.accent.toARGB32(),
          fillOpacity: 0.2,
        ),
      );

      await style.addLayer(
        LineLayer(
          id: lineLayerId,
          sourceId: polygonSourceId,
          lineColor: TColors.primary.toARGB32(),
          lineWidth: 2,
        ),
      );

      await mapboxMap!.style.addStyleImage(
        'incident-marker',
        0.6,
        markerIcon,
        false,
        [],
        [],
        null,
      );

      await style.addSource(
        GeoJsonSource(
          id: markerSourceId,
          data: jsonEncode({
            "type": "FeatureCollection",
            "features": markerFeatures,
          }),
        ),
      );

      await style.addLayer(
        SymbolLayer(id: markerLayerId, sourceId: markerSourceId)
          ..iconImage = 'incident-marker'
          ..iconSize = 0.028
          ..textField = '{name}'
          ..textSize = 12
          ..textColor = Colors.black.toARGB32()
          ..textHaloColor = Colors.white.toARGB32()
          ..textHaloWidth = 4.0
          ..textHaloBlur = 0.5
          ..textOffset = [0, -2]
          ..textAnchor = TextAnchor.BOTTOM
          ..textAllowOverlap = true
          ..iconAllowOverlap = true
          ..textFont = ['Roboto Regular'],
      );

    } catch (e) {
      debugPrint('❌ Failed to load polygons or markers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onMapClick(MapContentGestureContext context) {
    _handleMapClick(context.touchPosition);
    _handleIncidentMarkerTap(context.touchPosition);
  }

  Future<void> _handleMapClick(ScreenCoordinate screenCoordinate) async {
    try {
      final features = await mapboxMap!.queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate),
        RenderedQueryOptions(layerIds: ['incident-marker-layer']),
      );

      if (features.isEmpty) {
        debugPrint("⚠️ No features found at this coordinate");
        return;
      }

      final feature = features.first!.queriedFeature.feature;
      final rawProps = feature['properties'];

      if (rawProps is Map) {
        final featureMap = Map<String, dynamic>.from(features.first!.queriedFeature.feature);
        _showMarkerDetailsModal(Get.context!, featureMap);
      } else {
        debugPrint("⚠️ Feature has no valid properties: $rawProps");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to query features: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _showMarkerDetailsModal(BuildContext context, Map<String, dynamic> properties,) {
    debugPrint('🧩 Marker properties: $properties');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      showDragHandle: false,
      builder: (context) => CommuneOverviewWidget(feature: properties),
    );
  }

  void fetchCommuneOverviewData(String communeId) async {
    isOverviewLoading.value = true;

    try {
      final data = await liveMapService.fetchReportsByType(
        communeId: communeId,
        range: selectedRange.value,
      );

      traffic.value = data['Giao thông'] ?? 0;
      security.value = data['An ninh'] ?? 0;
      infrastructure.value = data['Cơ sở hạ tầng'] ?? 0;
      environment.value = data['Môi trường'] ?? 0;
      other.value = data['Khác'] ?? 0;
    } catch (e) {
      debugPrint('❌ Error fetching incident data: $e');
    } finally {
      isOverviewLoading.value = false;
    }
  }

  void updateCommuneOverviewRange(String range, String communeId) async {
    isOverviewLoading.value = true;

    try {
      selectedRange.value = range;

      final result = await liveMapService.fetchReportsByType(
        communeId: communeId,
        range: range,
      );

      traffic.value = result['Giao thông'] ?? 0;
      security.value = result['An ninh'] ?? 0;
      infrastructure.value = result['Cơ sở hạ tầng'] ?? 0;
      environment.value = result['Môi trường'] ?? 0;
      other.value = result['Khác'] ?? 0;
    } catch (e) {
      debugPrint('❌ Error fetching incident data: $e');
    } finally {
      isOverviewLoading.value = false;
    }
  }

  void initCommuneOverview(String communeId) {
    updateCommuneOverviewRange('week', communeId);
  }

  Future<void> loadIncidentIconsToMap() async {
    final iconMap = {
      'Giao thông': TImages.trafficMapIcon,
      'An ninh': TImages.securityMapIcon,
      'Môi trường': TImages.environmentMapIcon,
      'Cơ sở hạ tầng': TImages.infrastructureMapIcon,
      'Khác': TImages.otherMapIcon,
    };

    for (final entry in iconMap.entries) {
      try {
        final iconBytes = await getImage(entry.value);
        await mapboxMap!.style.addStyleImage(
          entry.key,
          0.6,
          iconBytes,
          false,
          [],
          [],
          null,
        );
      } catch (e) {
        debugPrint("⚠️ Failed to load icon for ${entry.key}: $e");
      }
    }
  }

  Future<void> focusOnCommune(Map<String, dynamic> feature) async {
    isCommuneReportFocusLoading.value = true;
    lastFocusedCommuneFeature = feature;

    try {
      final geometry = feature['geometry'];
      if (geometry == null || geometry['type'] != 'Point') {
        debugPrint("⚠️ Invalid geometry for focus");
        return;
      }

      final coords = geometry['coordinates'] as List<dynamic>;
      final double lng = coords[0].toDouble();
      final double lat = coords[1].toDouble();
      final center = Point(coordinates: Position(lng, lat));
      const radius = 0.045;

      final bounds = CoordinateBounds(
        southwest: Point(coordinates: Position(lng - radius, lat - radius)),
        northeast: Point(coordinates: Position(lng + radius, lat + radius)),
        infiniteBounds: false,
      );

      try {
        await mapboxMap!.style.setStyleLayerProperty(
          'incident-marker-layer',
          'visibility',
          'none',
        );
      } catch (_) {}

      await mapboxMap!.flyTo(
        CameraOptions(center: center, zoom: 14.5),
        MapAnimationOptions(duration: 1000),
      );

      await mapboxMap!.setBounds(
        CameraBoundsOptions(
          bounds: bounds,
          minZoom: 10.0,
          maxZoom: 19.0,
          maxPitch: 0,
        ),
      );

      final communeId = feature['properties']?['id']?.toString();
      if (communeId == null) {
        debugPrint('❌ Missing commune id');
        return;
      }

      final result = await liveMapService.fetchReportDetailsByType(
        communeId: communeId,
        type: selectedTypeApi,
        range: selectedRangeApi,
      );

      final bool isPremium = result['isPremium'] ?? true;

      if (!isPremium) {
        exitCommuneFocus();
        disableCommuneFocus();
        TLoaders.warningSnackBar(
          title: "Thông báo",
          message: "Bạn phải đăng ký gói để sử dụng chức năng này",
        );
        isCommuneReportFocusLoading.value = false;
        return;
      }

      final List<ReportDetailModel> reports = result['reports'];

      await loadIncidentIconsToMap();

      for (final id in ['incident-report-marker-layer', 'incident-report-marker-source']) {
        try {
          await mapboxMap!.style.removeStyleLayer(id);
        } catch (_) {}
        try {
          await mapboxMap!.style.removeStyleSource(id);
        } catch (_) {}
      }

      final features = reports.map((report) => {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [report.lng, report.lat],
        },
        "properties": {
          "icon": report.type,
          "id": report.id,
          "type": report.type,
          "subCategory": report.subCategory,
          "address": report.address,
          "lat": report.lat,
          "lng": report.lng,
          "occurredAt": report.occurredAt.toIso8601String(),
          "status": report.status,
        },
      }).toList();

      await mapboxMap!.style.addSource(
        GeoJsonSource(
          id: "incident-report-marker-source",
          data: jsonEncode({
            "type": "FeatureCollection",
            "features": features,
          }),
        ),
      );

      await mapboxMap!.style.addLayer(
        SymbolLayer(
          id: "incident-report-marker-layer",
          sourceId: "incident-report-marker-source",
          iconImageExpression: ["get", "icon"],
          iconSize: 0.036,
          iconAllowOverlap: true,
          iconIgnorePlacement: true,
        ),
      );

      isFocusedOnCommune.value = true;
    } catch (e, stackTrace) {
      debugPrint("❌ focusOnCommune failed: $e");
      debugPrint("🧱 $stackTrace");
    } finally {
      isCommuneReportFocusLoading.value = false;
    }
  }

  Future<void> refocusLastCommune() async {
    if (lastFocusedCommuneFeature != null) {
      await focusOnCommune(lastFocusedCommuneFeature!);
    }
  }

  Future<void> exitCommuneFocus() async {
    try {
      isExitingCommuneFocus.value = true;
      const centerLng = 106.67393252105423;
      const centerLat = 10.831951418898154;
      final center = Point(coordinates: Position(centerLng, centerLat));

      for (final id in ['incident-marker-layer', 'incident-marker-source']) {
        try {
          await mapboxMap!.style.removeStyleLayer(id);
        } catch (_) {}
        try {
          await mapboxMap!.style.removeStyleSource(id);
        } catch (_) {}
      }

      try {
        final markerIcon = await getImage(TImages.communesOverviewIcon);
        await mapboxMap!.style.addStyleImage(
          'incident-marker',
          0.6,
          markerIcon,
          false,
          [],
          [],
          null,
        );
      } catch (_) {}

      final rawDataList = await liveMapService.fetchCommunesPolygon();
      final List<Map<String, dynamic>> markerFeatures = [];

      for (final collection in rawDataList) {
        final features = collection['features'] as List<dynamic>;
        for (final feature in features) {
          final geometry = feature['geometry'];
          if (geometry['type'] == 'Point') {
            final coords = geometry['coordinates'];
            final lng = coords[0].toDouble();
            final lat = coords[1].toDouble();
            markerFeatures.add({
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [lng, lat],
              },
              "properties": feature['properties'],
            });
          }
        }
      }

      try {
        await mapboxMap!.style.setStyleLayerProperty(
          'incident-report-marker-layer',
          'visibility',
          'none',
        );
      } catch (_) {}

      await mapboxMap!.style.addSource(
        GeoJsonSource(
          id: "incident-marker-source",
          data: jsonEncode({
            "type": "FeatureCollection",
            "features": markerFeatures,
          }),
        ),
      );

      await mapboxMap!.style.addLayer(
        SymbolLayer(
          id: "incident-marker-layer",
          sourceId: "incident-marker-source",
        )..iconImage = 'incident-marker'
          ..iconSize = 0.028
          ..textField = '{name}'
          ..textSize = 12
          ..textColor = Colors.black.toARGB32()
          ..textHaloColor = Colors.white.toARGB32()
          ..textHaloWidth = 4.0
          ..textHaloBlur = 0.5
          ..textOffset = [0, -2]
          ..textAnchor = TextAnchor.BOTTOM
          ..textAllowOverlap = true
          ..iconAllowOverlap = true
          ..textFont = ['Roboto Regular'],
      );

      await mapboxMap!.flyTo(
        CameraOptions(center: center, zoom: 13.5),
        MapAnimationOptions(duration: 1000),
      );

      await mapboxMap!.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            southwest: center,
            northeast: center,
            infiniteBounds: true,
          ),
          minZoom: 13.0,
          maxZoom: 20.0,
        ),
      );
      isFocusedOnCommune.value = false;
    } catch (e) {
      debugPrint("❌ exitCommuneFocus failed: $e");
    }finally {
      isExitingCommuneFocus.value = false;
    }
  }

  Future<void> _handleIncidentMarkerTap(ScreenCoordinate screenCoordinate) async {
    try {
      final features = await mapboxMap!.queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate),
        RenderedQueryOptions(layerIds: ['incident-report-marker-layer']),
      );

      if (features.isEmpty) {
        debugPrint("⚠️ No incident markers found at this coordinate");
        return;
      }

      final rawFeature = features.first!.queriedFeature.feature;

      final feature = Map<String, dynamic>.from(
        rawFeature.map(
              (key, value) => MapEntry(key.toString(), value),
        ),
      );

      final rawProps = feature['properties'];
      if (rawProps == null || rawProps is! Map) {
        debugPrint("⚠️ Invalid properties in feature: $rawProps");
        return;
      }

      final props = Map<String, dynamic>.from(
        rawProps.map(
              (key, value) => MapEntry(key.toString(), value),
        ),
      );

      final report = ReportDetailModel(
        id: props['id'],
        communeId: 0,
        type: props['type'],
        subCategory: props['subCategory'],
        address: props['address'],
        lat: (props['lat'] as num).toDouble(),
        lng: (props['lng'] as num).toDouble(),
        occurredAt: DateTime.parse(props['occurredAt']),
        status: props['status'],
      );

      Get.bottomSheet(
        enableDrag: false,
        CommuneReportDetailsWidget(report: report),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    } catch (e, stackTrace) {
      debugPrint("❌ Failed to handle incident marker tap: $e");
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
